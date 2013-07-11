//
//  EffectApply.m
//  WizardWar
//
//  Created by Sean Hess on 7/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "EffectApply.h"
#import "Wizard.h"

@implementation EffectApply

-(SpellInteraction *)applySpell:(Spell *)spell onWizard:(Wizard *)wizard currentTick:(NSInteger)currentTick {
    wizard.effect = self;
    [self start:currentTick player:wizard];
    return [SpellInteraction cancel];
}

@end
