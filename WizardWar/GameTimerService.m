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
@end

@implementation GameTimerService

- (void)startAt:(NSTimeInterval)startTime {
    self.nextTickTime = startTime;
}

// make sure you start calling this by the time you call startAt
// If they pause I am SCREWED
// Or if animation lags?
// hmm, maybe this isn't such a good idea!

// Unless I sync constantly...
// Then I could start more quickly and kind of go from there. 

- (void)update:(NSTimeInterval)dt {
    self.localTime += dt;
    if (!self.nextTickTime) return;
    if (self.nextTickTime < self.localTime) {
        self.nextTickTime = self.nextTickTime + self.tickInterval;
        
        self.currentTick = self.nextTick;
        [self.delegate gameDidTick:self.currentTick];
    }
}

-(void)start {
    self.localTime = 0;
}

- (void)stop {
    self.nextTickTime = 0;
}

- (NSInteger)nextTick {
    return self.currentTick + 1;
}

@end
