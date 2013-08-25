//
//  AITacticCastOnHit.m
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITCastOnHit.h"
#import "NSArray+Functional.h"

@interface AITCastOnHit ()
@property (nonatomic) NSInteger lastWizardHealth;
@property (nonatomic) NSInteger lastOpponentHealth;
@end

@implementation AITCastOnHit

-(AIAction*)suggestedAction:(AIGameState *)game {
    
    AIAction * action;
    
    BOOL castHitSelf = (self.hitSelf && game.wizard.health < self.lastWizardHealth);
    BOOL castHitOpponent = (self.hitOpponent && game.opponent.health < self.lastOpponentHealth);
    
    if (!game.lastSpellCast || castHitSelf || castHitOpponent) {
        NSString * randomType = [self.spells randomItem];
        Spell * spell = [Spell fromType:randomType];
        action = [AIAction spell:spell];
        
        if (!game.lastSpellCast)
            action.priority = 10;
        
        self.lastWizardHealth = game.wizard.health;
        self.lastOpponentHealth = game.opponent.health;        
    }

    return action;
}

+(id)me:(BOOL)hitSelf opponent:(BOOL)hitOpponent random:(NSArray *)spells {
    AITCastOnHit * tactic = [AITCastOnHit new];
    tactic.spells = spells;
    tactic.hitOpponent = hitOpponent;
    tactic.hitSelf = hitSelf;
    return tactic;    
}

@end
