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
#import "Tick.h"

@implementation SpellIcewall

-(id)init {
    if ((self=[super init])) {
        self.speed = 0;
        self.startOffsetPosition = 15;
        self.castTimeInTicks = (int)round(TICKS_PER_SECOND * 0.5);
    }
    return self;
}

-(SpellInteraction *)interactSpell:(Spell *)spell {
    if ([spell isType:[SpellMonster class]]) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellFireball class]]) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellEarthwall class]] || [spell isType:[SpellIcewall class]]) {
        if (self.created < spell.created) // if older
            return [SpellInteraction cancel];
    }
    
    return [SpellInteraction nothing];
}

@end
