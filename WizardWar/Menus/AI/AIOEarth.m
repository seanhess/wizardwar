//
//  AIOEarth.m
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AIOEarth.h"
#import "UIColor+Hex.h"
#import "AITEffectRenew.h"
#import "AITDelay.h"
#import "AITCastOnClose.h"
#import "AITWallAlways.h"


@implementation AIOEarth
-(id)init {
    if ((self = [super init])) {
        Wizard * wizard = [Wizard new];
        wizard.name = [self.class name];
        wizard.wizardType = WIZARD_TYPE_ONE;
        wizard.color = [UIColor colorFromRGB:0x0];
        self.wizard = wizard;
        
        // Harder, he needs to dodge with levitate and helmet, depending on what is close
        // Tactic: If if spell is going to hit within X units, cast Y
        // AITCastOnClose (as late as possible, only if going to hit)
        
        // Just a raw spammer.
        // Let's see... he only casts earthwall, so he should wall always there.
        
        // TO CHANGE: only cast Helmet if you don't have one on.
        // Always do that on delay?
        
        self.tactics = @[
            [AITWallAlways walls:@[Earthwall]],
            [AITDelay random:@[Helmet, Monster]],
            [AITDelay random:@[Monster, Helmet, Monster, Vine]],
        ];
    }
    return self;
}

+(NSString*)name {
    return @"Talfan the Terramancer";
}

@end
