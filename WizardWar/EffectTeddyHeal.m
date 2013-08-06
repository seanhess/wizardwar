//
//  EffectTeddyHeal.m
//  WizardWar
//
//  Created by Sean Hess on 8/6/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "EffectTeddyHeal.h"
#import "Spell.h"
#import "Wizard.h"

@implementation EffectTeddyHeal

// Default effect applied to player, is to deal damage
-(SpellInteraction*)applySpell:(Spell*)spell onWizard:(Wizard*)wizard currentTick:(NSInteger)currentTick {
    wizard.health += 1;
    
    if (wizard.health > MAX_HEALTH)
        wizard.health = MAX_HEALTH;
    
    return [SpellInteraction cancel];
}

@end
