//
//  SpellHeal.m
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellHeal.h"
#import "PEHeal.h"

@implementation SpellHeal

-(id)initWithInfo:(SpellInfo *)info {
    if ((self=[super initWithInfo:info])) {
        self.speed = 0;
        self.damage = 0;
        self.targetSelf = YES;
        self.name = @"Heal";                
    }
    return self;
}

@end
