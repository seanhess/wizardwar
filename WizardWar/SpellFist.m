//
//  SpellFist.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellFist.h"
#import "SpellHelmet.h"

#define FIST_TIME_DROP_WAIT 2.0
#define FIST_TIME_DROP_DURATION 1.0

@implementation SpellFist

-(id)initWithInfo:(SpellInfo *)info {
    if ((self=[super initWithInfo:info])) {
        self.speed = 0;
        self.strength = 1;
        self.altitude = 2; // it's up high!
        self.name = @"Fist of Grom";
        self.castDelay = 3.0;
    }
    return self;
}

-(BOOL)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    
    NSInteger elapsedTicks = currentTick - self.createdTick;
    if (self.altitude == 2 && elapsedTicks >= round(FIST_TIME_DROP_WAIT/interval)) {
        self.altitude = 1;
    } else if (self.altitude == 1 && elapsedTicks >= round((FIST_TIME_DROP_WAIT+FIST_TIME_DROP_DURATION)/interval)) {
        self.altitude = 0;
    }
    
    return [super simulateTick:currentTick interval:interval];
}

-(void)setPositionFromPlayer:(Wizard*)player {
    self.direction = 1;
    
    if (player.position == UNITS_MIN)
        self.referencePosition = UNITS_MAX;
    else
        self.referencePosition = UNITS_MIN;
    
    self.position = self.referencePosition;
}


@end
