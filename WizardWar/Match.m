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
#import "TimerSyncService.h"
#import "PracticeModeAIService.h"

// sync spells to the server every N seconds
@interface Match () <GameTimerDelegate, MultiplayerDelegate, TimerSyncDelegate, AIDelegate>

// spells to be added at the next tick
@property (nonatomic, strong) NSString * lastCastSpellName;
@property (nonatomic, strong) GameTimerService * timer;
@property (nonatomic, strong) id<Multiplayer> multiplayer;
@property (nonatomic, strong) TimerSyncService * sync;
@property (nonatomic, strong) PracticeModeAIService * ai;

@property (nonatomic, strong) NSString * matchId;
@property (nonatomic, strong) Player * aiPlayer;

@end

@implementation Match
-(id)initWithId:(NSString *)matchId currentPlayer:(Player *)player withAI:(Player *)aiPlayer multiplayer:(id<Multiplayer>)multiplayer sync:(TimerSyncService *)sync {
    if ((self = [super init])) {
        self.matchId = matchId;
        self.players = [NSMutableDictionary dictionary];
        self.spells = [NSMutableDictionary dictionary];
        self.multiplayer = multiplayer;
        self.multiplayer.delegate = self;
        self.sync = sync;
        self.sync.delegate = self;
        self.status = MatchStatusReady;
        self.currentPlayer = player;
        self.aiPlayer = aiPlayer;
        
        if (self.aiPlayer) {
            self.ai = [PracticeModeAIService new];
            self.ai.delegate = self;
        }
    }
    return self;
}

-(void)connect {
    NSAssert(self.delegate, @"Delegate should be set before connect");
    if (self.aiPlayer) {
        [self addPlayer:self.aiPlayer];
    }
    
    [self addPlayer:self.currentPlayer];
    [self.multiplayer addPlayer:self.currentPlayer];
    
}

- (void)addSpell:(Spell*)spell {
    [self.spells setObject:spell forKey:spell.spellId];
    [self.delegate didAddSpell:spell];
}

- (void)removeSpell:(Spell*)spell {
    [self.spells removeObjectForKey:spell.spellId];
    [self.delegate didRemoveSpell:spell];
}

- (void)addPlayer:(Player*)player {
    [self.players setObject:player forKey:player.name];
    [self.delegate didAddPlayer:player];
    if (self.players.count == 2) [self playersReady];
}


/// AI //

- (void)aiDidCastSpell:(Spell *)spell {
    [self player:self.aiPlayer castSpell:spell];
}



/// UPDATES
// we only make changes locally if they haven't been made yet
// any time we make a change, make it locally first, then sync to remote
-(void)mpDidAddSpell:(Spell *)spell {
    if (![self.spells objectForKey:spell.spellId])
        [self addSpell:spell];
}

-(void)mpDidUpdate:(NSDictionary*)updates spellWithId:(NSString*)spellId {
    // doesn't matter if you run this more than once
    Spell * spell = [self.spells objectForKey:spellId];
    [spell setValuesForKeysWithDictionary:updates];
}

-(void)mpDidRemoveSpellWithId:(NSString*)spellId {
    Spell * spell = [self.spells objectForKey:spellId];
    if (spell) [self removeSpell:spell];
}

-(void)mpDidAddPlayer:(Player *)player {
    if (![self.players objectForKey:player.name])
        [self addPlayer:player];
}

-(void)mpDidUpdate:(NSDictionary *)updates playerWithName:(NSString *)name {
    Player * player = [self.players objectForKey:name];
    [player setValuesForKeysWithDictionary:updates];
    [self checkWin];
}

-(void)mpDidRemovePlayerWithName:(NSString *)name {
    // Someone disconnected
    Player * player = [self.players objectForKey:name];
    [self.players removeObjectForKey:name];
    [self.delegate didRemovePlayer:player];
    [self stop];
}



// STARTING
// sync player health and mana better
// ... send the player every so often
// ... every X ticks?

-(void)playersReady {
    NSLog(@"PLAYERS READY");
    
    // Sort the players
    NSArray * players = self.sortedPlayers;
    [(Player *)players[0] setPosition:UNITS_MIN];
    [(Player *)players[1] setPosition:UNITS_MAX];
    
    BOOL isHost = (self.currentPlayer == self.host);
    self.timer = [GameTimerService new];
    self.timer.tickInterval = TICK_INTERVAL;
    self.timer.delegate = self;
    
    // TODO; I only want to do this if the multiplayer so requires...
    if (self.sync)
        [self.sync syncTimerWithMatchId:self.matchId player:self.currentPlayer isHost:isHost];
    else
        [self gameShouldStartAt:CACurrentMediaTime() + 0.1];
}

- (void)gameShouldStartAt:(NSTimeInterval)startTime {
    [self.timer startAt:startTime];
}

-(void)update:(NSTimeInterval)dt {
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
    
    [self.ai simulateTick:currentTick interval:self.timer.tickInterval];
}

-(void)simulateTick:(NSInteger)currentTick {
    
    // Add all spells in the action queue
    // alter based on how many ticks they are off
    NSArray * newSpells = [self.spells.allValues filter:^BOOL(Spell *spell) {
        return spell.status == SpellStatusPrepare;
    }];
//    NSLog(@"TICK tick=%i queue=%i", currentTick, newSpells.count);
    [newSpells forEach:^(Spell * spell) {
        if (spell.createdTick > currentTick) {
            NSLog(@" !!! SPELL IN FUTURE");
        }
        else {
            NSLog(@" - %@", spell);
            spell.status = SpellStatusActive;
            NSInteger tickDifference = currentTick - spell.createdTick;
            [spell move:(tickDifference * self.timer.tickInterval)];
        }
    }];
    
    // run the simulation
    // try to simulate EVERYTHING, but allow yourself to be corrected by owner
    // in other words, go ahead and make all changes locally, but don't SYNC unless you own them
    [self checkHits];
    
    // Maybe sync the player every second
    if ((currentTick % (int)round(TICKS_PER_SECOND)) == 0) {
        //NSLog(@"SYNC PLAYER health=%i mana=%i", self.currentPlayer.health, self.currentPlayer.mana);
        [self.multiplayer updatePlayer:self.currentPlayer];
    }
    
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
            if ([spell hitsPlayer:player duringInterval:TICK_INTERVAL])
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

// this only matters
- (void)cleanupDestroyed {
    NSArray * oldSpells = [self.spells.allValues filter:^BOOL(Spell * spell) {
        return ((spell.status == SpellStatusDestroyed) && (spell.updatedTick < self.timer.nextTick-10));
    }];
    
    [oldSpells forEach:^(Spell * spell) {
        [self removeSpell:spell];
    }];
    
    NSArray * closeOldSpells = [oldSpells filter:^BOOL(Spell * spell) {
        return [self isSpellClose:spell];
    }];
    [self.multiplayer removeSpells:closeOldSpells];
}

-(NSArray*)activeSpells {
    return [self.spells.allValues filter:^BOOL(Spell * spell) {
        return spell.status == SpellStatusActive;
    }];
}

// Spells close to you are the ones you "own" in multiplayer
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
    spell.status = SpellStatusDestroyed;
    spell.updatedTick = self.timer.nextTick;
    
    // Only sync changes if owned spell and local player
    if ([self isSpellClose:spell])
        [self.multiplayer updateSpell:spell onTick:self.timer.nextTick];
    
    // only YOU can say you died
    if (player == self.currentPlayer || player == self.aiPlayer) {
        if (player.health == 0) {
            [player setState:PlayerStateDead animated:NO];
            [self checkWin];
        }
        
        [self.multiplayer updatePlayer:player];
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

-(void)handleInteraction:(SpellInteraction*)interaction forSpell:(Spell*)spell {
    
    if (interaction.type == SpellInteractionTypeCancel) {
        spell.status = SpellStatusDestroyed;
        spell.updatedTick = self.timer.nextTick;
        if ([self isSpellClose:spell])
            [self.multiplayer updateSpell:spell onTick:self.timer.nextTick];
    }
    
    else if (interaction.type == SpellInteractionTypeCreate) {
//        [self.spellsCollection addObject:spell];
    }
    
    else if (interaction.type == SpellInteractionTypeModify) {
        // reflections ... need to make sure you have it right!
        // TODO send tick information with reflection / updates, add to the action queue
        // so you can get them on the other client
        spell.updatedTick = self.timer.nextTick;
        if ([self isSpellClose:spell])
            [self.multiplayer updateSpell:spell onTick:self.timer.nextTick];
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

-(void)player:(Player*)player castSpell:(Spell*)spell {
    if (player.mana >= spell.mana) {
        [player spendMana:spell.mana];
        [player setState:PlayerStateCast animated:YES];
        NSLog(@"SPELL Cast %@", spell);
        
        // update spell
        [spell setPositionFromPlayer:player];
        [spell setSpellId:[Spell generateSpellId]];
        [spell setStatus:SpellStatusPrepare];
        
        // sync
        [self addSpell:spell];
        [self.multiplayer addSpell:spell onTick:self.timer.nextTick];
        [self.multiplayer updatePlayer:player]; // new mana total
    } else {
        NSLog(@"Not enough Mana you fiend!");
    }
}


-(void)castSpell:(Spell *)spell {
    [self player:self.currentPlayer castSpell:spell];
}

-(void)disconnect {
    [self.multiplayer removePlayer:self.currentPlayer];
    [self.multiplayer disconnect];
    [self.sync disconnect];
}

- (void)dealloc {
    NSLog(@"Match: dealloc");
}

@end
