//
//  PENone.m
//  WizardWar
//
//  Created by Sean Hess on 8/21/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "PENone.h"
#import "Wizard.h"
#import "Spell.h"

@implementation PENone

// Default effect applied to player, is to deal damage
-(BOOL)applySpell:(Spell*)spell onWizard:(Wizard*)wizard currentTick:(NSInteger)currentTick {
    return NO;
}

@end
