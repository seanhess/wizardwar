//
//  SpellWindblast.m
//  WizardWar
//
//  Created by Sean Hess on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellWindblast.h"

// Windblast just slows things down, etc

@implementation SpellWindblast

-(id)initWithInfo:(SpellInfo *)info {
    if ((self=[super initWithInfo:info])) {
        self.speed = 60;
        self.damage = 0;
        self.heavy = NO;
        self.name = @"Wind Blast";
        self.castDelay = 0.3;
    }
    return self;
}

@end
