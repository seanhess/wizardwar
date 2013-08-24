//
//  AIStrategyCast.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITacticCast.h"

// casts a spell
@implementation AITacticCast

-(AIAction*)suggestedAction:(AIGameState *)game {
    
    if (game.lastSpellCast && game.lastSpellCast == self.suggestedSpell)
        return nil;
    
    self.suggestedSpell = [Spell fromType:self.spellType];
    return [AIAction spell:self.suggestedSpell];
}

+(id)spell:(NSString*)spellType {
    AITacticCast * tactic = [AITacticCast new];
    tactic.spellType = spellType;
    return tactic;
}

@end
