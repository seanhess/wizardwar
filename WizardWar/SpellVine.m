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
#import "SpellFirewall.h"

#define TIME_UNTIL_ATTACK 3

@implementation SpellVine

-(id)init {
    if ((self=[super init])) {
        // TODO mana cost higher!
        // TODO harder to cast!
        self.name = @"Summon Vine";
        self.castDelay *= 2.5;
        self.speed = 0;
        self.startOffsetPosition = UNITS_MAX - SPELL_WALL_OFFSET_POSITION;
    }
    return self;
}

-(SpellInteraction *)interactSpell:(Spell *)spell currentTick:(NSInteger)currentTick {

    if ([spell isType:[SpellFirewall class]] && spell.direction != self.direction) {
        return [SpellInteraction cancel];
    }
    
    return [SpellInteraction nothing];
}

-(SpellInteraction *)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    NSInteger elapsedTicks = currentTick - self.createdTick;
    if (elapsedTicks >= round(TIME_UNTIL_ATTACK/interval)) {
        if (self.position < UNITS_MID)
            self.position = UNITS_MIN;
        else
            self.position = UNITS_MAX;
    }
    
    return nil;
}


@end
