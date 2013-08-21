//
//  SpellEarthwall.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellFirewall.h"
#import "SpellFireball.h"
#import "SpellMonster.h"
#import "SpellIcewall.h"
#import "SpellBubble.h"
#import "SpellEarthwall.h"
#import "Tick.h"

@implementation SpellFirewall

-(id)init {
    if ((self=[super init])) {
        self.damage = 1;
        self.strength = 3;
        self.name = @"Wall of Fire";
    }
    return self;
}

@end
