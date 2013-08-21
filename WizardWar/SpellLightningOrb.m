//
//  SpellLightningOrb.m
//  WizardWar
//
//  Created by Sean Hess on 8/12/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellLightningOrb.h"
#import "SpellEarthwall.h"
#import "SpellWindblast.h"
#import "SpellIcewall.h"
#import "SpellBubble.h"
#import "SpellMonster.h"
#import "SpellFireball.h"
#import "SpellFirewall.h"

@implementation SpellLightningOrb

-(id)init {
    if ((self=[super init])) {
        self.heavy = NO;
        self.name = @"Lightning Orb";
    }
    return self;
}





@end
