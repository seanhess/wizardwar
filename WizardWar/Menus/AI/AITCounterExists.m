//
//  AITCounterExists.m
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITCounterExists.h"
#import "NSArray+Functional.h"

@interface AITCounterExists ()
@property (nonatomic, strong) NSDictionary * countersCast;
@end

@implementation AITCounterExists

-(AIAction *)suggestedAction:(AIGameState *)game {
    
    AIAction * action;
    
    NSArray * incoming = game.incomingSpells;
    if (game.isCooldown) return nil;
    
    NSArray * knowCounter = [incoming filter:^BOOL(Spell * spell) {
        return self.counters[spell.type] != nil;
    }];
    
    
    // now, filter them by whether their counter is on the screen or not.
    // if the counter is not anything I have currently cast
    NSArray * mySpells = game.mySpells;
    NSArray * noCounterCast = [knowCounter filter:^BOOL(Spell*spell) {
        NSString * counterType = self.counters[spell.type];
        return ![game spells:mySpells containsType:counterType];
    }];
    
    if (!noCounterCast.count) return nil;
    
    NSArray * closest = [game sortSpellsByDistance:noCounterCast];
    
    Spell * spell = closest[0];
    Spell * counter = [Spell fromType:self.counters[spell.type]];
    action = [AIAction spell:counter priority:4];
    
    return action;
    
}

+(id)counters:(NSDictionary *)counters {
    AITCounterExists * tactic = [AITCounterExists new];
    tactic.counters = counters;
    return tactic;
}

@end
