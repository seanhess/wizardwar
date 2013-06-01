//
//  SpellVine.m
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
#import "Tick.h"

@implementation SpellVine

-(id)init {
    if ((self=[super init])) {
        // TODO mana cost higher!
        // TODO harder to cast!
        self.castTimeInTicks = (int)round(TICKS_PER_SECOND * 2.0); // really, should be a # of ticks
    }
    return self;
}

-(SpellInteraction *)interactSpell:(Spell *)spell {
    return [SpellInteraction nothing];
}

@end
