//
//  SpellEarthwall.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellFirewall.h"

@implementation SpellFirewall

-(id)initWithInfo:(SpellInfo *)info {
    if ((self=[super initWithInfo:info])) {
        self.damage = 1;
        self.strength = 3;
        self.name = @"Wall of Fire";
    }
    return self;
}

@end
