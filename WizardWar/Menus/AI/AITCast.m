//
//  AIStrategyCast.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITCast.h"

// casts a spell
@implementation AITCast

-(AIAction*)suggestedAction:(AIGameState *)game {
    // wipe the timer if you change tactics
    // casts the spell if different from lastcastspell
    if (game.isCooldown) return nil;
    if (![game.lastSpellCast isType:self.spellType]) {
        Spell * spell = [Spell fromType:self.spellType];
        return [AIAction spell:spell];
    }
    return nil;
}

+(id)spell:(NSString*)spellType {
    AITCast * tactic = [AITCast new];
    tactic.spellType = spellType;
    return tactic;
}

@end
