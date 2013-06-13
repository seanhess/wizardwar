//
//  EffectLevitate.m
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "EffectLevitate.h"
#import "Player.h"

#define EFFECT_LEVITATE_DURATION 3

@implementation EffectLevitate

-(id)init {
    self = [super init];
    if (self) {
        self.cancelsOnHit = YES;
    }
    return self;
}

// TODO

-(void)start:(NSInteger)tick player:(Player *)player {
    [super start:tick player:player];
    player.altitude = 1;
}

-(void)cancel:(Player*)player {
    [super cancel:player];
    player.altitude = 0;
    
    // should the player take damage here if he falls?
    // no, hard to differentiate between switching effects
}

// ok, so I need to check to see if they've waited long enough to heal
// it can only heal ONE heart
// if you get hit in the meantime it doesn't work
-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval player:(Player*)player {
    NSInteger ticksPerDuration = round(EFFECT_LEVITATE_DURATION / interval);
    if ((currentTick - self.startTick) >= ticksPerDuration) {
        player.effect = nil;
        player.altitude = 0;
    }
}

@end
