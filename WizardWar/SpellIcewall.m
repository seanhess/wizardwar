//
//  SpellIcewall.m
//  WizardWar
//
//  Created by Sean Hess on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellIcewall.h"
#import "SpellFireball.h"
#import "SpellEarthwall.h"
#import "SpellMonster.h"
#import "SpellBubble.h"
#import "SpellVine.h"
#import "SpellWindblast.h"
#import "SpellLightningOrb.h"
#import "Tick.h"

@implementation SpellIcewall

-(id)init {
    if ((self=[super init])) {
        self.name = @"Wall of Ice";
    }
    return self;
}

@end
