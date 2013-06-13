//
//  SpellLevitate.m
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellLevitate.h"
#import "EffectLevitate.h"

@implementation SpellLevitate

-(id)init {
    if ((self=[super init])) {
        self.speed = 0;
        self.damage = 0;
        self.effect = [EffectLevitate new];
        self.visual = NO;
    }
    return self;
}

@end
