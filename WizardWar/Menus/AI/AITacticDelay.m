//
//  AITacticDelay.m
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITacticDelay.h"
#import "Spell.h"
#import "NSArray+Functional.h"

@implementation AITacticDelay

-(AIAction*)suggestedAction:(AIGameState *)game {
    
    AIAction * action;
    
    if (!game.isCooldown) {
        NSString * randomType = [self.spells randomItem];
        Spell * spell = [Spell fromType:randomType];
        action = [AIAction spell:spell time:self.delay];
    }
    
    return action;
}


+(id)random:(NSArray*)spells delay:(NSTimeInterval)delay {
    AITacticDelay * tactic = [AITacticDelay new];
    tactic.spells = spells;
    tactic.delay = delay;
    return tactic;
}

@end
