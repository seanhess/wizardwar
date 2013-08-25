//
//  AIOJumper.m
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AIOJumper.h"
#import "UIColor+Hex.h"
#import "AITEffectRenew.h"
#import "PELevitate.h"
#import "AITDelay.h"

// This guy just stays flying

// RETURNS: he dodges like a boss using helmet. Casts Levitate or Helmet depending on what is close. 

@implementation AIOJumper
-(id)init {
    if ((self = [super init])) {
        Wizard * wizard = [Wizard new];
        wizard.name = [AIOJumper name];
        wizard.wizardType = WIZARD_TYPE_ONE;
        wizard.color = [UIColor colorFromRGB:0x0];
        self.wizard = wizard;
        
        // Should jump immediately. Cast jump again if it's about to end.
        // Should cast other random spells from a list
        // Never bothers with silly walls
        
        // Does he cast it before he lands? YES
        // Does he recast it if you knock him down? YES, immediately. He always wants to fly
        
        self.tactics = @[
             [AITEffectRenew effect:[PELevitate new] spell:Levitate],
//             [AITDelay random:@[Monster, Chicken, Vine, Monster]],
        ];
    }
    return self;
}

+(NSString*)name {
    return @"Flying Fionnghal";
}

@end
