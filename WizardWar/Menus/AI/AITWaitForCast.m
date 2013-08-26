//
//  AITWaitForCast.m
//  WizardWar
//
//  Created by Sean Hess on 8/26/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITWaitForCast.h"
#import "NSArray+Functional.h"

@implementation AITWaitForCast


-(AIAction *)suggestedAction:(AIGameState *)game {
    
    Spell * myLastSpell = [game.mySpells max:^float(Spell * spell) {
        return spell.createdTick;
    }];

    Spell * opponentLastSpell = [game.mySpells max:^float(Spell * spell) {
        return spell.createdTick;
    }];
    
    if (!opponentLastSpell) return nil;
    if (myLastSpell && myLastSpell.createdTick >= opponentLastSpell.createdTick)
        return nil;
    
    // Now grab a new spell
    NSString * randomType = [self.spells randomItem];
    Spell * spell = [Spell fromType:randomType];
    
    return [AIAction spell:spell];
}

+(id)random:(NSArray*)random {
    AITWaitForCast * tactic = [AITWaitForCast new];
    tactic.spells = random;
    return tactic;
}
@end
