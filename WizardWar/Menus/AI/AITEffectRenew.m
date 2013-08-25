//
//  AITEffectRenew.m
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITEffectRenew.h"

// re-casts a particular spell as soon as it's about to wear off?
// If you ever don't have an effect active, renew it immediately. 

@implementation AITEffectRenew

-(AIAction *)suggestedAction:(AIGameState *)game {

    AIAction * action;
    if (game.isCooldown) return nil;
    
    NSLog(@"*** %@", game.wizard.effect);
    
    if (game.wizard.effect == nil || ![game.wizard.effect isKindOfClass:[self.effect class]]) {
        action = [AIAction spell:[Spell fromType:self.spellType] priority:10];
    }
    
    return action;
}

+(id)effect:(PlayerEffect*)effect spell:(NSString*)spell {
    AITEffectRenew * tactic = [AITEffectRenew new];
    tactic.effect = effect;
    tactic.spellType = spell;
    return tactic;
}

@end
