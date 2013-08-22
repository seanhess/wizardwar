//
//  EffectLevitate.m
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "PELevitate.h"
#import "Wizard.h"

#define EFFECT_LEVITATE_DURATION 4.5

@implementation PELevitate

-(id)init {
    self = [super init];
    if (self) {
        self.cancelsOnHit = YES;
    }
    return self;
}

// TODO

-(void)start:(NSInteger)tick player:(Wizard *)player {
    [super start:tick player:player];
    player.altitude = 1;
}

-(void)cancel:(Wizard*)player {
    player.altitude = 0;
    [super cancel:player];
}

-(BOOL)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval player:(Wizard*)player {
    NSInteger ticksPerDuration = round(EFFECT_LEVITATE_DURATION / interval);
    if ((currentTick - player.effectStartTick) >= ticksPerDuration) {
        NSLog(@"DROPPING %@ %i", player.name, player.effectStartTick);
        player.effect = nil;
        player.altitude = 0;
    }
    return NO;
}

@end
