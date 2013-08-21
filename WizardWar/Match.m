//
//  Match.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Match.h"
#import "Spell.h"
#import "Wizard.h"
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
#import <ReactiveCocoa.h>
#import "GameTimerService.h"
#import "TimerSyncService.h"
#import "PracticeModeAIService.h"
#import "Tick.h"
#import "AIService.h"
#import "SpellEffectService.h"

#define CLEANUP_TICKS 50 // 10 is 1 second
#define MIN_READY_STATE 2.5

// sync spells to the server every N seconds
@interface Match () <GameTimerDelegate, MultiplayerDelegate, TimerSyncDelegate, AIDelegate>

// spells to be added at the next tick
@property (nonatomic, strong) NSString * lastCastSpellName;
@property (nonatomic, strong) GameTimerService * timer;
@property (nonatomic, strong) id<Multiplayer> multiplayer;
@property (nonatomic, strong) TimerSyncService * sync;
@property (nonatomic, strong) id<AIService> ai;

@property (nonatomic, strong) NSMutableDictionary * players;
@property (nonatomic, strong) NSMutableDictionary * spells;

@property (nonatomic, strong) NSString * hostName;
@property (nonatomic, strong) Wizard * aiWizard;

@property (nonatomic) BOOL enoughTimeAsReady;

@property (nonatomic, strong) SpellEffectService * effects;

@end

// Always use a challenge!
@implementation Match
-(id)initWithMatchId:(NSString *)matchId hostName:(NSString *)hostName currentWizard:(Wizard *)wizard withAI:(id<AIService>)ai multiplayer:(id<Multiplayer>)multiplayer sync:(TimerSyncService *)sync {
    if ((self = [super init])) {
        self.matchId = matchId;
        self.hostName = hostName;
        self.players = [NSMutableDictionary dictionary];
        self.spells = [NSMutableDictionary dictionary];
        self.sortedPlayers = [NSMutableArray array];
        self.multiplayer = multiplayer;
        self.multiplayer.delegate = self;
        self.sync = sync;
        self.sync.delegate = self;
        self.status = MatchStatusReady;
        self.currentWizard = wizard;
        
        self.ai = ai;
        self.ai.delegate = self;
        self.aiWizard = ai.wizard;
        
        self.effects = [SpellEffectService new];
        
        self.enoughTimeAsReady = NO;
    }
    return self;
}

-(void)connect {
    NSAssert(self.delegate, @"Delegate should be set before connect");
    if (self.aiWizard) {
        [self addPlayer:self.aiWizard];
    }
    
    [self.multiplayer connectToMatchId:self.matchId];
    
    [self addPlayer:self.currentWizard];
    [self.multiplayer addPlayer:self.currentWizard];
    
    __weak Match * wself = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MIN_READY_STATE * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        wself.enoughTimeAsReady = YES;
    });
}

- (void)addSpell:(Spell*)spell {
    spell.position = spell.referencePosition;
    if (!spell.creator) {
        [spell initCaster:[self otherWizard:self.currentWizard] tick:spell.createdTick];
    }
    [self.spells setObject:spell forKey:spell.spellId];
    [self.delegate didAddSpell:spell];
}

- (void)removeSpell:(Spell*)spell {
    [self.spells removeObjectForKey:spell.spellId];
    [self.delegate didRemoveSpell:spell];
}

- (void)addPlayer:(Wizard*)player {
    NSLog(@"ADD PLAYER %@", player.name);
    [self.players setObject:player forKey:player.name];
    
    if ([player.name isEqualToString:self.hostName]) {
        player.position = UNITS_MIN;        
        [self.sortedPlayers insertObject:player atIndex:0];
    }
    else {
        player.position = UNITS_MAX;
        [self.sortedPlayers addObject:player];
    }
    
    [self.delegate didAddPlayer:player];
    [self startIfReady];
}

- (void)removePlayer:(Wizard*)player {
    [self.players removeObjectForKey:player.name];
    [self.delegate didRemovePlayer:player];
    [self.sortedPlayers removeObject:player];
    
    if (self.status == MatchStatusPlaying || self.status == MatchStatusSyncing)
        [self stop];
}






/// AI //

- (void)aiDidCastSpell:(Spell *)spell {
    [self player:self.aiWizard castSpell:spell currentTick:self.timer.nextTick];
}


/// UPDATES
// we only make changes locally if they haven't been made yet
// any time we make a change, make it locally first, then sync to remote
-(void)mpDidAddSpell:(Spell *)spell {
    if (![self.spells objectForKey:spell.spellId]) {
        // it must be from the other guy!
        // Force to be prepare. Sometimes they can set to Destroyed immediately, and it never registers as prepare over here
        spell.status = SpellStatusPrepare;
        [self addSpell:spell];
    }
}

-(void)mpDidUpdate:(NSDictionary*)updates spellWithId:(NSString*)spellId {
    // doesn't matter if you run this more than once
    
    Spell * spell = [self.spells objectForKey:spellId];
    BOOL wasPrepare = spell.status == SpellStatusPrepare;
    
    [spell setValuesForKeysWithDictionary:updates];

    // Force to be prepare. Sometimes they can set to Destroyed immediately, and it never registers as prepare over here
    if (wasPrepare && spell.status == SpellStatusDestroyed)
        spell.status = SpellStatusPrepare;
}

-(void)mpDidRemoveSpellWithId:(NSString*)spellId {
    Spell * spell = [self.spells objectForKey:spellId];
    if (spell) [self removeSpell:spell];
}

-(void)mpDidAddPlayer:(Wizard *)player {
    if (![self.players objectForKey:player.name])
        [self addPlayer:player];
}

-(void)mpDidUpdate:(NSDictionary *)updates playerWithName:(NSString *)name {
    Wizard * player = [self.players objectForKey:name];
    [player setValuesForKeysWithDictionary:updates];
    [self checkWin];
}

-(void)mpDidRemovePlayerWithName:(NSString *)name {
    // Someone disconnected
    Wizard * player = [self.players objectForKey:name];
    [self removePlayer:player];
}

-(void)startIfReady {
    if (self.players.count < 2) return;
    
    NSLog(@"Match: starting...");
    
    BOOL isHost = (self.currentWizard == self.host);
    self.timer = [GameTimerService new];
    self.timer.tickInterval = TICK_INTERVAL;
    self.timer.delegate = self;
    [self.timer start];
    
    if (self.sync) {
        self.status = MatchStatusSyncing;
        [self.sync syncTimerWithMatchId:self.matchId player:self.currentWizard isHost:isHost timer:self.timer];
    }
    else {
        self.status = MatchStatusSyncing;
    }
        
}

-(void)gameIsSynchronized {
    self.status = MatchStatusPlaying;
}

-(void)update:(NSTimeInterval)dt {
    [self.timer update:dt];
}

- (void)gameDidTick:(NSInteger)currentTick {
    if (!self.enoughTimeAsReady) return;
    if (self.status == MatchStatusSyncing && currentTick >= GAME_TIMER_FIRST_TICK) {
        self.status = MatchStatusPlaying;
    }
    [self simulateTick:currentTick interval:self.timer.tickInterval];
    [self.delegate didTick:currentTick];
}

-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)tickInterval {
//    NSLog(@"(%i) simulate", currentTick);
    [self simulateUpdatedSpells:currentTick interval:tickInterval];
    
    // SIMULATE PLAYERS. Players handle simulating their own effects
    [self.players.allValues forEach:^(Wizard * player) {
        [player simulateTick:currentTick interval:tickInterval];
    }];
    
    // SIMULATE SPELLS
    // move before checking hits, then we check hits with didHit
    // = whether or not they passed each other during that interval
    [self.activeSpells forEach:^(Spell * spell) {
        BOOL changed = [spell simulateTick:currentTick interval:tickInterval];
        if (changed)
            [self modifySpell:spell];
    }];
    
    // COLLISIONS: detect whether they are about to hit or not
    // do this first, or we won't be able to detect whether they collide or not
    // run the simulation
    // try to simulate EVERYTHING, but allow yourself to be corrected by owner
    // in other words, go ahead and make all changes locally, but don't SYNC unless you own them
    [self checkHitsWithCurrentTick:currentTick interval:tickInterval];
    
    // HACK: sync the player every second
    // this happens because I allow the spells to modify the player, but there's no way for them
    // to return a player modification event.
    if ((currentTick % (int)round(TICKS_PER_SECOND)) == 0) {
        [self.multiplayer updatePlayer:self.currentWizard];
    }
    
    [self cleanupDestroyed];
    
    // SIMULATE AI
    [self.ai simulateTick:currentTick interval:tickInterval];
    
    // SYNC EVERYTHING?
    // This might be the better way to go, if we changed it to be set up to handle updates better
//    [[self.activeSpells filter:^BOOL(Spell*spell) {
//        return [self isSpellClose:spell] && (spell.speed > 0);
//    }] forEach:^(Spell* spell) {
//        [self modifySpell:spell];
//    }];
}

-(void)simulateUpdatedSpells:(NSInteger)currentTick interval:(NSTimeInterval)tickInterval {
    NSArray * updatedSpells = [self.spells.allValues filter:^BOOL(Spell * spell) {
        return (spell.status == SpellStatusUpdated);
    }];
    
    NSArray * newSpells = [self.spells.allValues filter:^BOOL(Spell *spell) {
        return spell.status == SpellStatusPrepare;
    }];
    
    [updatedSpells forEach:^(Spell * spell) {
//        NSLog(@"UPDATED SPELL %@", spell.name);
        [self positionSpell:spell referenceTick:spell.updatedTick currentTick:currentTick];
    }];
    
    [newSpells forEach:^(Spell * spell) {
        NSLog(@"(%i) NEW SPELL %@", currentTick, spell.name);
        Wizard * creator = spell.creator;
        
        if (creator.effect.cancelsOnCast)
            creator.effect = nil;
        
        if (spell.targetSelf) {
            [self hitPlayer:creator withSpell:spell interval:tickInterval atTick:currentTick];
        }
        else {
            [self positionSpell:spell referenceTick:spell.createdTick currentTick:currentTick];
        }
    }];
}

-(void)positionSpell:(Spell*)spell referenceTick:(NSInteger)referenceTick currentTick:(NSInteger)currentTick {
    NSInteger tickDifference = currentTick - referenceTick;
    if (tickDifference < 0) NSLog(@"******************SPELL IN FUTURE*****************");
    spell.position = [spell moveFromReferencePosition:(tickDifference * self.timer.tickInterval)];
    spell.status = SpellStatusActive;
}

// does a spell automatically change the effect?
//-(void)createSpell:(Spell*)spell effect:(Effect*)effect {
//    Wizard * player = [self.players.allValues min:^float(Wizard*player) {
//        return fabsf(spell.position - player.position);
//    }];
//    
//    // destroy the effect spell
//    spell.updatedTick = self.timer.nextTick;
//    spell.status = SpellStatusDestroyed;
//    
//    // apply the effect
//    player.effect = effect;
//    [effect start:spell.createdTick player:player];
//}

-(void)checkHitsWithCurrentTick:(NSInteger)currentTick interval:(NSTimeInterval)tickInterval {
    
    // Things with linkedSpells go last
    // Then, older spells go last (they apply more strongly)
    // No bubble steal
    NSArray * spells = [self.activeSpells sortedArrayUsingComparator:^NSComparisonResult(Spell * one, Spell * two) {
//        if (one.spellEffect && !two.spellEffect) return NSOrderedDescending;
//        else if (!one.spellEffect && two.spellEffect) return NSOrderedAscending;
        if (one.createdTick > two.createdTick) return NSOrderedAscending;
        else if (one.createdTick < two.createdTick) return NSOrderedDescending;
        else return NSOrderedSame;
    }];
    
    NSArray * players = self.players.allValues;
    for (int i = 0; i < spells.count; i++) {
        Spell * spell = spells[i];
        
        // spells are center anchored, so just check the position, not the width
        // see if spell hits ME (don't check the other player)
        for (Wizard * player in players) {
            if ([spell hitsPlayer:player duringInterval:tickInterval])
                [self hitPlayer:player withSpell:spell interval:tickInterval atTick:currentTick];
        }
        
        // start at the next spell (don't check collisons twice)
        for (int j = i+1; j < spells.count; j++) {
            Spell * spell2 = spells[j];
            if ([spell didHitSpell:spell2 duringInterval:self.timer.tickInterval]) {
                [self hitSpell:spell withSpell:spell2 interval:tickInterval currentTick:currentTick];
            }
        }
    }
}

// this only matters
- (void)cleanupDestroyed {
    NSInteger oldestValidUpdatedTick = self.timer.nextTick - 10;
    NSArray * oldSpells = [self.spells.allValues filter:^BOOL(Spell * spell) {
        return ((spell.status == SpellStatusDestroyed) && (spell.updatedTick < oldestValidUpdatedTick)) || ((spell.status == SpellStatusActive && (spell.position < UNITS_MIN-UNITS_DISTANCE || spell.position > UNITS_MAX+UNITS_DISTANCE)));
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

-(NSArray*)activeOrUpdatedSpells {
    return [self.spells.allValues filter:^BOOL(Spell * spell) {
        return spell.status == SpellStatusActive || spell.status == SpellStatusUpdated;
    }];
}

// Spells close to you are the ones you "own" in multiplayer
-(BOOL)isSpellClose:(Spell*)spell {
//    NSLog(@" - isSpellClose pos=%i play=%i mid=%f", (int)spell.position, self.currentWizard.isFirstPlayer, UNITS_MID);
    if (self.currentWizard.isFirstPlayer) {
        return (spell.position < UNITS_MID);
    }
    else {
        return (spell.position >= UNITS_MID);
    }
}

-(void)hitPlayer:(Wizard*)wizard withSpell:(Spell*)spell interval:(NSTimeInterval)interval atTick:(NSInteger)currentTick {
    
    Wizard * clone = [wizard evilClone];
    BOOL spellModified = [self interactWizard:clone spell:spell interval:interval currentTick:currentTick];
    if (spellModified)
        [self modifySpell:spell];

    // Now copy the wizard changes into your current wizard
    // Maybe it would have been easier to do it like this for the spells too?
    // EXCEPT health, wait and see if we have multiplayer first
    
    // position can't change right now, it breaks the animation on levitate
    wizard.altitude = clone.altitude;
    wizard.updatedTick = clone.updatedTick;
    
    if (clone.effectStartTick != wizard.effectStartTick) {
        if (wizard.effect != clone.effect) {
            [wizard.effect cancel:wizard];
            wizard.effect = clone.effect;
        }
        [wizard.effect start:currentTick player:wizard];
//        NSLog(@"(%i) CHANGED EFFECT", currentTick);
    }

    if (wizard.state != clone.state) {
        [wizard setStatus:clone.state atTick:currentTick];
    }
    
    
    // handle player sync / update / death check
    // only YOU can say you died
    if (wizard == self.currentWizard || wizard == self.aiWizard) {
        
        wizard.health = clone.health;
        
        if (wizard.health == 0) {
            wizard.effect = nil;
            [wizard setState:WizardStatusDead];
            // need to set the OTHER wizard to something else
            Wizard * otherWizard = [self otherWizard:wizard];
            otherWizard.effect = nil;
            [otherWizard setState:WizardStatusWon];

            [self.multiplayer updatePlayer:otherWizard];
            [self checkWin];
        }

        [self.multiplayer updatePlayer:wizard];
    }
}

-(void)hitSpell:(Spell*)spell withSpell:(Spell*)spell2 interval:(NSTimeInterval)interval currentTick:(NSInteger)currentTick {
    NSArray * interactions = [self.effects interactionsForSpell:spell.type andSpell:spell2.type];
    
    for (SpellInteraction * interaction in interactions) {
        Spell * main;
        Spell * other;
        
        // at this point, we are SURE they apply to both
        if ([spell.type isEqualToString:interaction.spell]) {
            main = spell;
            other = spell2;
            // Woah, hack for if they are both the same class
            // since I didn't make the assumption there would always be two interactions
            if ([spell2.type isEqualToString:interaction.spell] && interaction == interactions[1]) {
                main = spell2;
                other = spell;
            }
        } else {
            main = spell2;
            other = spell;
        }
        
        [self interact:interaction main:main other:other interval:interval currentTick:currentTick];
    }
}

-(void)interact:(SpellInteraction*)interaction main:(Spell*)main other:(Spell*)other interval:(NSTimeInterval)interval currentTick:(NSInteger)currentTick {
    
    NSLog(@"INTERACT %@ %@ %@", interaction.effect, main.name, other.name);
    
    BOOL modified = [interaction.effect applyToSpell:main otherSpell:other tick:currentTick];
    
    if (modified) {
        [self modifySpell:main];
        
        // it's not just main, it's either?
        
        // LINKED SPELLS should match their link's position, speed, direction, etc
        NSArray * linkedSpells = [self spellsLinkedToSpell:main];
        NSLog(@" - changed %i", linkedSpells.count);
        [linkedSpells forEach:^(Spell * spell) {
            if (spell.linkedSpell.strength == 0) {
                spell.strength = 0;
            } else {
                spell.position = spell.linkedSpell.position;
                spell.speed = spell.linkedSpell.speed;
                spell.direction = spell.linkedSpell.direction;
            }
            [self modifySpell:spell];
        }];
    }
}

-(BOOL)interactWizard:(Wizard *)wizard spell:(Spell*)spell interval:(NSTimeInterval)interval currentTick:(NSInteger)currentTick {
    
    // If the wizard has an effect, give it the chance to override the default behavior
    if (wizard.effect) {
        BOOL intercepted = [wizard.effect interceptSpell:spell onWizard:wizard interval:interval currentTick:currentTick];
        if (intercepted) return YES;
    }
    
    // otherwise apply the effect full force
    PlayerEffect * effect = [self.effects playerEffectForSpell:spell.type];
    return [effect applySpell:spell onWizard:wizard currentTick:currentTick];
}


-(NSArray*)spellsLinkedToSpell:(Spell*)parent {
    return [self.activeOrUpdatedSpells filter:^BOOL(Spell*spell) {
        return (spell.linkedSpell == parent);
    }];
}

-(void)checkWin {
    [self.players.allValues forEach:^(Wizard* player) {
        if (player.state == WizardStatusDead) {
            [self stop];
        }
    }];
}

-(Wizard*)host {
    return self.sortedPlayers[0];
}

-(void)stop {
    self.status = MatchStatusEnded;
    [self.timer stop];
}

-(void)destroySpell:(Spell*)spell {
    spell.strength = 0;
    [self modifySpell:spell];
}

-(void)modifySpell:(Spell*)spell {
//    NSLog(@" - modifySpell %@ close=%i", spell, [self isSpellClose:spell]);
    if (spell.strength > 0)
        spell.status = SpellStatusUpdated;
    else
        spell.status = SpellStatusDestroyed;
    spell.updatedTick = self.timer.nextTick;
    spell.referencePosition = spell.position;

    if ([self isSpellClose:spell]) {
        [self.multiplayer updateSpell:spell];
    }
}

-(BOOL)player:(Wizard*)player castSpell:(Spell*)spell currentTick:(NSInteger)currentTick {
    
    if (player.effect.disablesPlayer) return NO;
    
    NSLog(@"(%i) CAST SPELL", currentTick);
    
    [player setStatus:WizardStatusCast atTick:currentTick];
    
    // update spell
    [spell initCaster:player tick:self.timer.nextTick];
    
    // sync
    [self addSpell:spell];
    [self.multiplayer addSpell:spell];
    [self.multiplayer updatePlayer:player]; // new mana total?
    
    return YES;
}


-(BOOL)castSpell:(Spell *)spell {
    [self.ai opponent:self.currentWizard didCastSpell:spell atTick:self.timer.nextTick];
    return [self player:self.currentWizard castSpell:spell currentTick:self.timer.nextTick];
}

-(Wizard*)otherWizard:(Wizard*)wizard {
    return [self.players.allValues find:^BOOL(Wizard* aWizard) {
        return (aWizard != wizard);
    }];
}

-(void)disconnect {
    [self.multiplayer removePlayer:self.currentWizard];
    [self.multiplayer disconnect];
    [self.sync disconnect];
}

- (void)dealloc {
    NSLog(@"Match: dealloc");
    
    // SAME THING HERE
    // you should NEVER be connected to more than one match at a time
    // add something that forces you to know!
}

@end
