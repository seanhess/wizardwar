//
//  SpellFailChicken.m
//  WizardWar
//
//  Created by Sean Hess on 8/1/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellFailChicken.h"
#import "SpellWall.h"

@implementation SpellFailChicken

-(id)init {
    if ((self=[super init])) {
        self.name = @"Summon Chicken";
        self.damage = 3;
    }
    return self;
}

@end
