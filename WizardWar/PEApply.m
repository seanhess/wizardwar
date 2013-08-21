//
//  EffectApply.m
//  WizardWar
//
//  Created by Sean Hess on 7/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "PEApply.h"
#import "Wizard.h"
#import "Spell.h"

@implementation PEApply

-(BOOL)applySpell:(Spell *)spell onWizard:(Wizard *)wizard currentTick:(NSInteger)currentTick {

    if (wizard.effect) {
        [wizard.effect cancel:wizard];
    }
    
    wizard.effect = self;
    [self start:currentTick player:wizard];
    spell.strength = 0;
    return YES;
}

@end
