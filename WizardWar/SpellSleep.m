//
//  SpellSleep.m
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellSleep.h"
#import "SpellMonster.h"
#import "SpellIcewall.h"
#import "PESleep.h"
#import "SpellBubble.h"

@implementation SpellSleep

-(id)initWithInfo:(SpellInfo *)info {
    if ((self=[super initWithInfo:info])) {
        self.damage = 0;
        self.heavy = NO;
        self.name = @"Sleep";        
    }
    return self;
}

@end
