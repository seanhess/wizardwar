//
//  GameTimerService.m
//  WizardWar
//
//  Created by Sean Hess on 5/27/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "GameTimerService.h"
#import "NSArray+Functional.h"


@interface GameTimerService ()
@property (nonatomic) NSInteger currentTick;
@property (nonatomic) NSTimeInterval nextTickTime;
@property (nonatomic) CGFloat currentTime;
@end

@implementation GameTimerService

- (void)startAt:(NSTimeInterval)startTime {
    self.nextTickTime = startTime;
}

// make sure you start calling this by the time you call startAt
- (void)update:(NSTimeInterval)dt {
    self.currentTime += dt;
    if (!self.nextTickTime) return;
    if (self.nextTickTime < self.currentTime) {
        self.nextTickTime = self.nextTickTime + self.tickInterval;
        
        self.currentTick = self.nextTick;
        [self.delegate gameDidTick:self.currentTick];
    }
}

- (void)start {
    NSAssert(self.tickInterval, @"Must set tick interval > 0");
    self.currentTick = 0;
}

- (void)stop {
    self.nextTickTime = 0;
}

- (NSInteger)nextTick {
    return self.currentTick + 1;
}

@end
