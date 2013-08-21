//
//  SpellFireball.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellFireball.h"
#import "SpellEarthwall.h"
#import "SpellWindblast.h"
#import "SpellIcewall.h"
#import "SpellBubble.h"
#import "SpellMonster.h"
#import "SpellLightningOrb.h"

@implementation SpellFireball

-(id)init {
    if ((self=[super init])) {
//        self.speed = 40; // make it slower so you can do the windblast combo
//        self.speed = 25;
        self.heavy = NO;
        self.name = @"Fireball";
    }
    return self;
}


@end
