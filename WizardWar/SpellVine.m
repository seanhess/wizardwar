//
//  SpellVine.m
//  WizardWar
//
//  Created by Sean Hess on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellVine.h"
#import "SpellWall.h"
#import "Tick.h"

#define TIME_UNTIL_ATTACK_START 1.5
#define TIME_UNTIL_ATTACK_END 3

@interface SpellVine ()
@end

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

-(void)setPositionFromPlayer:(Wizard*)player {
    [super setPositionFromPlayer:player];
    self.altitude = -1;
}

-(BOOL)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    NSInteger elapsedTicks = currentTick - self.createdTick;
    NSInteger ticksUntilAttackStart = round(TIME_UNTIL_ATTACK_START/interval);
    NSInteger ticksUntilAttackEnd = round(TIME_UNTIL_ATTACK_END/interval);
    if (elapsedTicks >= ticksUntilAttackEnd + 4) {
        self.strength = 0;
        return YES;
    } else if (elapsedTicks >= ticksUntilAttackEnd) {
        if (self.position < UNITS_MID)
            self.position = UNITS_MIN;
        else
            self.position = UNITS_MAX;
    } else if (elapsedTicks >= ticksUntilAttackStart) {
        self.altitude = 0;
    }
    
    return NO;
}


@end
