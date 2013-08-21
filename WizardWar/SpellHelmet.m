//
//  SpellFist.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellHelmet.h"
#import "PEHelmet.h"

@implementation SpellHelmet

-(id)init {
    if ((self=[super init])) {
        self.speed = 0;
        self.damage = 0;
        self.targetSelf = YES;
        self.name = @"Mighty Helmet";
    }
    return self;
}

@end
