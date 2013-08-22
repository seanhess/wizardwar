//
//  EffectSleep.m
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "PESleep.h"
#import "Spell.h"

#define EFFECT_SLEEP_DURATION 5

@implementation PESleep

-(id)init {
    self = [super init];
    if (self) {
        self.disablesPlayer = YES;
    }
    return self;
}

+(BOOL)sleepShouldEndAtTick:(NSInteger)currentTick interval:(NSTimeInterval)interval started:(NSInteger)startedTick {
    NSInteger ticksPerDuration = round(EFFECT_SLEEP_DURATION / interval);
    return ((currentTick - startedTick) >= ticksPerDuration);
}

-(BOOL)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval player:(Wizard *)player {
    if ([PESleep sleepShouldEndAtTick:currentTick interval:interval started:player.effectStartTick]) {
        player.effect = nil;
    }
    return NO;
}

@end
