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


@interface Match ()
@property (nonatomic, strong) Firebase * matchNode;
@property (nonatomic, strong) Firebase * spellsNode;
@property (nonatomic, strong) Firebase * playersNode;
@property (nonatomic, strong) Firebase * opponentNode;

@property (nonatomic, strong) FirebaseCollection *spellsCollection;
@property (nonatomic, strong) FirebaseCollection *playersCollection;

@property (nonatomic, strong) NSString * lastCastSpellName;
@end

// don't really know which player you are until there are 2 players
// then you can go off their name.
// Alphabetical order baby :)

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
            // TODO set it back in time to original position when it is accepted
            [wself addedSpellLocally:spell];
        }];
        
        [self.spellsCollection didRemoveChild:^(Spell * spell) {
            [wself.delegate didRemoveSpell:spell];
        }];
        
        
        // PLAYERS
        self.playersCollection = [[FirebaseCollection alloc] initWithNode:self.playersNode dictionary:self.players type:[Player class]];
        
        [self.playersCollection didAddChild:^(Player * player) {
            [wself.delegate didAddPlayer:player];
            if (wself.players.count == 2) [wself start];
        }];
        
        if (ai) {
            self.opponentPlayer = ai;
            [self.playersCollection addObject:ai];
        }
        
        self.currentPlayer = player;
        [self.playersCollection addObject:self.currentPlayer];

//        [[NSNotificationCenter defaultCenter] addObserverForName:@"HealthManaUpdate" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
//            [self.delegate didUpdateHealthAndMana];
//        }];
    }
    return self;
}


/// UPDATES

-(void)update:(NSTimeInterval)dt {
    [self.spells.allValues forEach:^(Spell*spell) {
        [spell update:dt];
    }];
    
    [self.players.allValues forEach:^(Player*player) {
        [player update:dt];
    }];
    
    [self checkHits];
}

-(void)checkHits {
    // HITS ARE CALLED MORE THAN ONCE!
    // A hits B, B hits A
    NSArray * spells = self.spells.allValues;
    for (int i = 0; i < spells.count; i++) {
        Spell * spell = spells[i];
        // spells are center anchored, so just check the position, not the width?
        // TODO add spell size to the equation
        // check to see if the spell hits ME, not all players
        // or check to see how my spells hit?
        for (Player * player in self.players.allValues)  {
            if ([spell hitsPlayer:player])
                [self hitPlayer:player withSpell:spell];
        }
        
        for (int j = i+1; j < spells.count; j++) {
            Spell * spell2 = spells[j];
            if ([spell hitsSpell:spell2])
                [self hitSpell:spell withSpell:spell2];
        }
    }
}

-(void)hitPlayer:(Player*)player withSpell:(Spell*)spell {
    [self.spellsCollection removeObject:spell];
    
    // this allows it to subtract health
    [spell interactPlayer:player];
    [self checkWin];
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
//        Firebase * node = [self.spellsNode childByAppendingPath:spell.firebaseName];
//        [node setValue:spell.toObject];
    }
    
    else if (interaction.type == SpellInteractionTypeNothing) {
        // do nothing
    }
    
    else {
        NSAssert(false, @"Did not understand spell interaction type");
    }
    
}

// STARTING

-(void)checkStart {
    if (self.players.count >= 2) {
        [self start];
    }
}

-(void)start {
    self.status = MatchStatusPlaying;
    NSArray * players = self.sortedPlayers;
    [(Player *)players[0] setPosition:UNITS_MIN];
    [(Player *)players[1] setPosition:UNITS_MAX];
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
        [self.spellsCollection addObject:spell];
        [self.currentPlayer setState:PlayerStateCast animated:YES];
    } else {
        NSLog(@"Not enough Mana you fiend!");
    }
}

- (void)disconnect {
    [self.spellsNode removeAllObservers];
    [self.playersNode removeAllObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
//    [self disconnect];
    NSLog(@"Match: dealloc");
}

@end
