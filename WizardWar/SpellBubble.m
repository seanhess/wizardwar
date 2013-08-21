//
//  SpellBubble.m
//  WizardWar
//
//  Created by Sean Hess on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellBubble.h"
#import "SpellMonster.h"
#import "SpellFireball.h"
#import "SpellIcewall.h"
#import "SpellVine.h"
#import "SpellWindblast.h"

@implementation SpellBubble

-(id)init {
    if ((self=[super init])) {
        self.damage = 0;
        self.heavy = NO;
        self.speed = 20;
        self.name = @"Bubble";
    }
    return self;
}

@end
