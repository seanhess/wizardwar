//
//  SpellLightningOrb.m
//  WizardWar
//
//  Created by Sean Hess on 8/12/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellLightningOrb.h"

@implementation SpellLightningOrb

-(id)initWithInfo:(SpellInfo *)info {
    if ((self=[super initWithInfo:info])) {
        self.heavy = NO;
        self.name = @"Lightning Orb";
    }
    return self;
}





@end
