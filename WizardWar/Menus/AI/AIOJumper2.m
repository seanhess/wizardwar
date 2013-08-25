//
//  AIOJumper.m
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AIOJumper2.h"
#import "UIColor+Hex.h"
#import "AITEffectRenew.h"
#import "PELevitate.h"
#import "AITDelay.h"
#import "AITCastOnClose.h"

// RETURNS: he dodges like a boss using helmet. Casts Levitate or Helmet depending on what is close.

@implementation AIOJumper2
-(id)init {
    if ((self = [super init])) {
        Wizard * wizard = [Wizard new];
        wizard.name = [AIOJumper2 name];
        wizard.wizardType = WIZARD_TYPE_ONE;
        wizard.color = [UIColor colorFromRGB:0x0];
        self.wizard = wizard;
        
        // Harder, he needs to dodge with levitate and helmet, depending on what is close
        // Tactic: If if spell is going to hit within X units, cast Y
        // AITCastOnClose (as late as possible, only if going to hit)
        
        self.tactics = @[
            [AITCastOnClose distance:20.0 highSpell:Helmet lowSpell:Levitate],
            [AITDelay random:@[Monster, Chicken, Vine, Monster, Lightning]],
        ];
    }
    return self;
}

+(NSString*)name {
    return @"Fionnghal Returns";
}

@end
