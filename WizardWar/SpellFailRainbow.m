//
//  SpellFailRainbow.m
//  WizardWar
//
//  Created by Sean Hess on 8/1/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellFailRainbow.h"

#define FIST_RAINBOW_DURATION 3.0

@implementation SpellFailRainbow

-(id)init {
    if ((self=[super init])) {
        self.name = @"Double Rainbow";
        self.speed = 0;
        self.startOffsetPosition = 50;
        self.damage = 0;        
    }
    return self;
}

-(BOOL)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    NSInteger elapsedTicks = currentTick - self.createdTick;
    if (elapsedTicks >= round(FIST_RAINBOW_DURATION/interval)) {
        self.strength = 0;
        return YES;
    }

    return NO;
}


@end
