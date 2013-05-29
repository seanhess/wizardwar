//
//  Match.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Match.h"
#import "Spell.h"
#import "Player.h"
#import <Firebase/Firebase.h>
#import "NSArray+Functional.h"
#import "SpellBubble.h"
#import "SpellEarthwall.h"
#import "SpellFireball.h"
#import "SpellIcewall.h"
#import "SpellMonster.h"
#import "SpellVine.h"
#import "SpellWindblast.h"
#import "SimpleAudioEngine.h"
#import "FirebaseCollection.h"
#import <ReactiveCocoa.h>
#import "GameTimerService.h"

// sync spells to the server every N seconds
@interface Match () <GameTimerDelegate>
@property (nonatomic, strong) Firebase * matchNode;
@property (nonatomic, strong) Firebase * spellsNode;
@property (nonatomic, strong) Firebase * playersNode;
@property (nonatomic, strong) Firebase * opponentNode;

@property (nonatomic, strong) FirebaseCollection * playersCollection;

// spells to be added at the next tick
@property (nonatomic, strong) NSMutableArray * actionQueue;

@property (nonatomic, strong) NSString * lastCastSpellName;
@property (nonatomic, strong) GameTimerService * timer;
@end

// don't really know which player you are until there are 2 players
// then you can go off their name.
// Alphabetical order baby :)
// How do you know who is who?

@implementation Match
-(id)initWithId:(NSString *)id currentPlayer:(Player *)player withAI:(Player *)ai {
    if ((self = [super init])) {
        self.players = [NSMutableDictionary dictionary];
        self.spells = [NSMutableDictionary dictionary];
        self.actionQueue = [NSMutableArray array];
        
        self.status = MatchStatusReady;
        
        __weak Match * wself = self;
        
        // Firebase
        self.matchNode = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wizardwar.firebaseio.com/match/%@", id]];
        self.spellsNode = [self.matchNode childByAppendingPath:@"spells"];
        self.playersNode = [self.matchNode childByAppendingPath:@"players"];
        
        // SPELLS
        [self.spellsNode observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot*snapshot) {
            // there is a new spell to add, add it to the queue
            Spell * spell = [Spell fromType:snapshot.value[@"type"]];
            spell.spellId = snapshot.name;
            [spell setValuesForKeysWithDictionary:snapshot.value];
            [wself.actionQueue addObject:spell];
        }];
        
        [self.spellsNode observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot*snapshot) {
            // destroyed (strength = 0)
            // speed = 0, etc.
            Spell * spell = [wself.spells objectForKey:snapshot.name];
            [spell setValuesForKeysWithDictionary:snapshot.value];
        }];
        
        [self.spellsNode observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot*snapshot) {
            Spell * spell = [wself.spells objectForKey:snapshot.name];
            [wself.spells removeObjectForKey:spell.spellId];
            [wself.delegate didRemoveSpell:spell];
        }];
        
        // TODO remove spells locally after they've been destroyed for a while (finished their animations)
        
        // PLAYERS
        self.playersCollection = [[FirebaseCollection alloc] initWithNode:self.playersNode dictionary:self.players type:[Player class]];
        
        [self.playersCollection didAddChild:^(Player * player) {
            [wself.delegate didAddPlayer:player];
            if (wself.players.count == 2) [wself playersReady];
        }];
        
        [self.playersCollection didUpdateChild:^(Player * player) {
            [wself checkWin];
        }];
        
        [self.playersCollection didRemoveChild:^(Player * player) {
            // Someone disconnected
            [wself.delegate didRemovePlayer:player];
            [wself stop];
        }];
        
        if (ai) {
            self.opponentPlayer = ai;
            [self.playersCollection addObject:ai];
        }
        
        self.currentPlayer = player;
        [self.playersCollection addObject:self.currentPlayer];
    }
    return self;
}



/// UPDATES


// STARTING

-(void)playersReady {
    NSLog(@"PLAYERS READY");
    
    // Sort the players
    NSArray * players = self.sortedPlayers;
    [(Player *)players[0] setPosition:UNITS_MIN];
    [(Player *)players[1] setPosition:UNITS_MAX];
    
    BOOL isHost = (self.currentPlayer == self.host);
    self.timer = [[GameTimerService alloc] initWithMatchNode:self.matchNode player:self.currentPlayer isHost:isHost];
    self.timer.tickInterval = TICK_INTERVAL;
    self.timer.delegate = self;
    [self.timer sync];
}

- (void)gameShouldStartAt:(NSTimeInterval)startTime {
    [self.timer startAt:startTime];
}
-(void)update:(NSTimeInterval)dt {
    if (self.status == MatchStatusEnded) return;
    [self.timer update:dt];
    
    if (self.status == MatchStatusReady) return;
    
    // move all the spells around and stuff, but don't simulate the game
    [self.activeSpells forEach:^(Spell*spell) {
        [spell update:dt];
    }];
    
    [self.players.allValues forEach:^(Player*player) {
        [player update:dt];
    }];
}

- (void)gameDidTick:(NSInteger)currentTick {
    if (currentTick == GAME_TIMER_FIRST_TICK)
        self.status = MatchStatusPlaying;
    [self simulateTick:currentTick];
    [self.delegate didTick:currentTick];
}

-(void)simulateTick:(NSInteger)currentTick {
    
    // Add all spells in the action queue
    // alter based on how many ticks they are off
    [self.actionQueue forEach:^(Spell * spell) {
        if (spell.createdTick > currentTick) {
            NSLog(@" !!! SPELL IN FUTURE");
        }
        else {
            NSInteger tickDifference = currentTick - spell.createdTick;
            [spell move:(tickDifference * self.timer.tickInterval)];
            
            [self.spells setObject:spell forKey:spell.spellId];
            [self addedSpellLocally:spell];
        }
    }];
    self.actionQueue = [NSMutableArray array];
    
    // run the simulation
    // try to simulate EVERYTHING, but allow yourself to be corrected by owner
    // in other words, go ahead and make all changes locally, but don't SYNC unless you own them
    [self checkHits];
    
    [self cleanupDestroyed];
}

-(void)checkHits {
    // HITS ARE CALLED MORE THAN ONCE!
    // A hits B, B hits A
    NSArray * spells = self.activeSpells;
    NSArray * players = self.players.allValues;
    for (int i = 0; i < spells.count; i++) {
        Spell * spell = spells[i];
        
        // spells are center anchored, so just check the position, not the width
        // see if spell hits ME (don't check the other player)
        for (Player * player in players) {
            if ([spell hitsPlayer:player])
                [self hitPlayer:player withSpell:spell];
        }
        
        // start at the next spell (don't check collisons twice)
        for (int j = i+1; j < spells.count; j++) {
            Spell * spell2 = spells[j];
            if ([spell hitsSpell:spell2 duringInterval:TICK_INTERVAL])
                [self hitSpell:spell withSpell:spell2];
        }
    }
}

- (void)cleanupDestroyed {
    [[self.spells.allValues filter:^BOOL(Spell * spell) {
        return spell.destroyed && (spell.updatedTick < self.timer.nextTick-10) && [self isSpellClose:spell];
    }] forEach:^(Spell *spell) {
        Firebase * node = [self.spellsNode childByAppendingPath:spell.spellId];
        [node removeValue];
    }];
}

// spells that are close to my side of the screen
// these are the ones I "own" -- I decide where they are, collisions, etc
-(NSArray*)closeSpells {
    return [self.spells.allValues filter:^BOOL(Spell * spell) {
        return [self isSpellClose:spell];
    }];
}

-(NSArray*)activeSpells {
    return [self.spells.allValues filter:^BOOL(Spell * spell) {
        return !spell.destroyed;
    }];
}

-(BOOL)isSpellClose:(Spell*)spell {
    if (self.currentPlayer.isFirstPlayer) {
        return (spell.position < UNITS_MID);
    }
    else {
        return (spell.position >= UNITS_MID);
    }
}

-(void)hitPlayer:(Player*)player withSpell:(Spell*)spell {
    // this allows it to subtract health
    [spell interactPlayer:player];
    spell.destroyed = YES;
    
    // Only sync changes if owned spell and local player
    if ([self isSpellClose:spell])
        [self sendUpdateSpell:spell];
    
    if (player == self.currentPlayer) {
        // only YOU can say you died
        if (player.health == 0)
            [player setState:PlayerStateDead animated:NO];
        
        [self.playersCollection updateObject:player];
    }
}

-(void)hitSpell:(Spell*)spell withSpell:(Spell*)spell2 {
    NSLog(@"HIT %@ %@", spell, spell2);
    [self handleInteraction:[spell interactSpell:spell2] forSpell:spell];
    [self handleInteraction:[spell2 interactSpell:spell] forSpell:spell2];
}

-(void)checkWin {
    [self.players.allValues forEach:^(Player* player) {
        if (player.state == PlayerStateDead) {
            [self stop];
        }
    }];
}

- (void)sendUpdateSpell:(Spell*)spell {
    spell.updatedTick = self.timer.nextTick;
    Firebase * node = [self.spellsNode childByAppendingPath:spell.spellId];
    [node setValue:spell.toObject];
}

-(void)handleInteraction:(SpellInteraction*)interaction forSpell:(Spell*)spell {
    
    if (interaction.type == SpellInteractionTypeCancel) {
        spell.destroyed = YES;
        if ([self isSpellClose:spell])
            [self sendUpdateSpell:spell];
    }
    
    else if (interaction.type == SpellInteractionTypeCreate) {
//        [self.spellsCollection addObject:spell];
    }
    
    else if (interaction.type == SpellInteractionTypeModify) {
        // reflections ... need to make sure you have it right!
        // TODO send tick information with reflection / updates, add to the action queue
        // so you can get them on the other client
        if ([self isSpellClose:spell])
            [self sendUpdateSpell:spell];
    }
    
    else if (interaction.type == SpellInteractionTypeNothing) {
        // do nothing
    }
    
    else {
        NSAssert(false, @"Did not understand spell interaction type");
    }
    
}

-(Player*)host {
    return self.sortedPlayers[0];
}

-(void)start {
    self.status = MatchStatusPlaying;
}

-(void)stop {
    self.status = MatchStatusEnded;
    [self.timer stop];
}

- (NSArray*)sortedPlayers {
    // sort players alphabetically (so it is the same on all devices)
    return [self.players.allValues sortedArrayUsingComparator:^NSComparisonResult(Player * p1, Player *p2) {
        return [p1.name compare:p2.name];
    }];
}



- (void)addedSpellLocally:(Spell*)spell {
    [self.delegate didAddSpell:spell];
    
    if([spell isMemberOfClass: [SpellFireball class]]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"fireball.wav"];//play a sound
    } else if([spell isMemberOfClass: [SpellEarthwall class]]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"earthwall.wav"];//play a sound
    } else if([spell isMemberOfClass: [SpellVine class]]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"vine.wav"];//play a sound
    } else if([spell isMemberOfClass: [SpellBubble class]]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"bubble.wav"];//play a sound
    } else if([spell isMemberOfClass: [SpellIcewall class]]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"icewall.wav"];//play a sound
    } else if([spell isMemberOfClass: [SpellMonster class]]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"monster.wav"];//play a sound
    } else if([spell isMemberOfClass: [SpellWindblast class]]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"windblast.wav"];//play a sound
    }
}

-(void)castSpell:(Spell *)spell {
    if (self.currentPlayer.mana >= spell.mana) {
        [self.currentPlayer spendMana:spell.mana];
        [self.currentPlayer setState:PlayerStateCast animated:YES];
        NSLog(@"SPELL Cast %@", spell);
        
        // update spell
        [spell setPositionFromPlayer:self.currentPlayer];
        [spell setCreatedTick:self.timer.nextTick];
        
        // add to firebase. It will be added to the queue when firebase calls the child added event
        
        Firebase * node = [self.spellsNode childByAutoId];
        [node onDisconnectRemoveValue];
        [node setValue:spell.toObject];
        
        // update your mana, etc
        [self.playersCollection updateObject:self.currentPlayer];
    } else {
        NSLog(@"Not enough Mana you fiend!");
    }
}

- (void)disconnect {
    [self.playersCollection removeObject:self.currentPlayer];
    [self.spellsNode removeAllObservers];
    [self.playersNode removeAllObservers];
}

- (void)dealloc {
    NSLog(@"Match: dealloc");
}

@end
