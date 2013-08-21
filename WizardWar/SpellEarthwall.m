//
//  SpellEarthwall.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellEarthwall.h"

@implementation SpellEarthwall

-(id)initWithInfo:(SpellInfo *)info {
    if ((self=[super initWithInfo:info])) {
        self.strength = 3;
        self.name = @"Wall of Earth";
    }
    return self;
}

@end
