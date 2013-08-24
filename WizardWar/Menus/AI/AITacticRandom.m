//
//  AITacticRandom.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITacticRandom.h"
#import "NSArray+Functional.h"

@interface AITacticRandom ()
@property (nonatomic) NSInteger lastHealth;
@end

@implementation AITacticRandom

-(AIAction*)suggestedAction:(AIGameState *)game {
    
    AIAction * action;
    
    if (self.castOnHit) {
        if (!game.lastSpellCast || game.wizard.health < self.lastHealth) {
            NSString * randomType = [self.spells randomItem];
            Spell * spell = [Spell fromType:randomType];
            action = [AIAction spell:spell];
        }
    }
    
    else if (!game.isCooldown) {
        NSString * randomType = [self.spells randomItem];
        Spell * spell = [Spell fromType:randomType];
        action = [AIAction spell:spell time:self.delay];
    }
    
    self.lastHealth = game.wizard.health;
    
    return action;
}


+(id)spells:(NSArray*)spells delay:(NSTimeInterval)delay {
    AITacticRandom * tactic = [AITacticRandom new];
    tactic.spells = spells;
    tactic.delay = delay;
    return tactic;
}

+(id)spellsCastOnHit:(NSArray *)spells {
    AITacticRandom * tactic = [AITacticRandom new];
    tactic.spells = spells;
    tactic.castOnHit = YES;
    return tactic;
}

@end
