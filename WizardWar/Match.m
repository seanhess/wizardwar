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
#define SPELL_SYNC_TIME 0.5

@interface Match () <GameTimerDelegate>
@property (nonatomic, strong) Firebase * matchNode;
@property (nonatomic, strong) Firebase * spellsNode;
@property (nonatomic, strong) Firebase * playersNode;
@property (nonatomic, strong) Firebase * opponentNode;

@property (nonatomic, strong) FirebaseCollection *spellsCollection;
@property (nonatomic, strong) FirebaseCollection *playersCollection;

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
        
        self.status = MatchStatusReady;
        
        __weak Match * wself = self;
        
        // Firebase
        self.matchNode = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wizardwar.firebaseio.com/match/%@", id]];
        self.spellsNode = [self.matchNode childByAppendingPath:@"spells"];
        self.playersNode = [self.matchNode childByAppendingPath:@"players"];
        
        // SPELLS
        self.spellsCollection = [[FirebaseCollection alloc] initWithNode:self.spellsNode dictionary:self.spells factory:^(NSDictionary*value) {
            return [Spell fromType:value[@"type"]];
        }];
        
        [self.spellsCollection didAddChild:^(Spell * spell) {
//            [wself addedSpellLocally:spell];
            [wself.actionQueue addObject:spell];
        }];
        
        [self.spellsCollection didRemoveChild:^(Spell * spell) {
            [wself.delegate didRemoveSpell:spell];
        }];
        
//        [self.spellsCollection didUpdateChild:^(Spell * spell) {
//            
//        }];
        
        
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
            wself.status = MatchStatusEnded;
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
    [self.timer update:dt];
    
    // move all the spells around and stuff, but don't simulate the game
    [self.spells.allValues forEach:^(Spell*spell) {
        [spell update:dt];
    }];
    
    [self.players.allValues forEach:^(Player*player) {
        [player update:dt];
    }];
}

- (void)gameDidTick:(NSInteger)currentTick {
    [self simulateTick:currentTick];
    [self.delegate didTick:currentTick];
}

-(void)simulateTick:(NSInteger)currentTick {
    // get new interactions on the queue that match the current tick
    // get any interactions for previous ticks, and re-simulate those to get the new local state
    
    // holy crap, this is nutso
    // I need an object that represents the current game state
    // then I can keep a few historic ones in case I need to run them again
    
    // it would be great to keep old copies of them around
    // is there another way?
    // you could try to reverse it (hard!)
    // you could ignore interactions in the past (do this at first)
        // just set the POSITION of objects in the past based on their speed and tick, etc
    
    // the STATE of the simulation is
        // 1. the state of all the spells
        // 2. the state of the players (health, mana, etc)
    
    // ONE TICK: directions are constant. See if spells MOVE THROUGH each other during that period
    // can't keep your current algorithm, because they might pass through each other?
    // naw, just don't make them that skinny
    
    // now, run the simulation
    // speed is already in units per second
    // run the simulation for the next game tick
    [self checkHits];
}

-(void)checkHits {
    // HITS ARE CALLED MORE THAN ONCE!
    // A hits B, B hits A
    NSArray * spells = self.closeSpells;
    for (int i = 0; i < spells.count; i++) {
        Spell * spell = spells[i];
        // spells are center anchored, so just check the position, not the width
        // see if spell hits ME (don't check the other player)
        if ([spell hitsPlayer:self.currentPlayer])
            [self hitPlayer:self.currentPlayer withSpell:spell];
        
        // start at the next spell (don't check collisons twice)
        for (int j = i+1; j < spells.count; j++) {
            Spell * spell2 = spells[j];
            if ([spell hitsSpell:spell2])
                [self hitSpell:spell withSpell:spell2];
        }
    }
}

// spells that are close to my side of the screen
// these are the ones I "own" -- I decide where they are, collisions, etc
-(NSArray*)closeSpells {
    return [self.spells.allValues filter:^BOOL(Spell * spell) {
        return [self isSpellClose:spell];
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
    [self.spellsCollection removeObject:spell];
    // this allows it to subtract health
    [spell interactPlayer:player];
    [self.playersCollection updateObject:player];
}

-(void)hitSpell:(Spell*)spell withSpell:(Spell*)spell2 {
    NSLog(@"HIT %@ %@", spell, spell2);
    [self handleInteraction:[spell interactSpell:spell2] forSpell:spell];
    [self handleInteraction:[spell2 interactSpell:spell] forSpell:spell2];
}

-(void)checkWin {
    [self.players.allValues forEach:^(Player* player) {
        if (player.health == 0) {
            [player setState:PlayerStateDead animated:NO];
            self.status = MatchStatusEnded;
        }
    }];
}

-(void)handleInteraction:(SpellInteraction*)interaction forSpell:(Spell*)spell {
    if (interaction.type == SpellInteractionTypeCancel) {
        [self.spellsCollection removeObject:spell];
    }
    
    else if (interaction.type == SpellInteractionTypeCreate) {
        [self.spellsCollection addObject:spell];
    }
    
    else if (interaction.type == SpellInteractionTypeModify) {
        [self.spellsCollection updateObject:spell];
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
        [spell setPositionFromPlayer:self.currentPlayer];
        [self.currentPlayer setState:PlayerStateCast animated:YES];
        NSLog(@"SPELL Cast %@", spell);
        spell.connected = NO; // only happens locally
        
        // you need to inform them right away, but not update right away
        [self.spellsCollection addObject:spell onComplete:^(NSError*error) {
            NSLog(@"SPELL Connected %@", spell);
            spell.connected = YES;
        }];
        [self.playersCollection updateObject:self.currentPlayer];
    } else {
        NSLog(@"Not enough Mana you fiend!");
    }
}

- (void)disconnect {
    [self.playersCollection removeObject:self.currentPlayer];
    [self.spellsNode removeAllObservers];
    [self.playersNode removeAllObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    NSLog(@"Match: dealloc");
}

@end
