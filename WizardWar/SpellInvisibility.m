//
//  SpellInvisibility.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellInvisibility.h"

@implementation SpellInvisibility

-(id)initWithInfo:(SpellInfo *)info {
    if ((self=[super initWithInfo:info])) {
        self.speed = 0;
        self.damage = 0;
        self.targetSelf = YES;
        self.name = @"Invisibility";
    }
    return self;
}

@end
