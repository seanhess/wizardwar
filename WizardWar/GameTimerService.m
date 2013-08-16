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
    self.gameTime += dt;
    if (!self.nextTickTime) return;
    [self simulateTicks];
}

-(void)simulateTicks {
    NSTimeInterval timePastNextTick = self.gameTime - self.nextTickTime;
    while (timePastNextTick > 0) {
        self.nextTickTime = self.nextTickTime + self.tickInterval;
        
        self.currentTick = self.nextTick;
        [self.delegate gameDidTick:self.currentTick];
        timePastNextTick -= self.tickInterval;
    }
}

-(void)start {
    self.gameTime = 0;
    self.nextTickTime = self.gameTime + self.tickInterval;
}

- (void)stop {
    self.nextTickTime = 0;
}

- (NSInteger)nextTick {
    return self.currentTick + 1;
}

- (void)startFromRemoteTime:(GameTime *)gameTime {    
    self.gameTime = gameTime.gameTime;
    self.nextTickTime = gameTime.nextTickTime;
    self.currentTick = gameTime.nextTick - 1;
    [self simulateTicks];
}

- (void)updateFromRemoteTime:(NSTimeInterval)gameTime {
    self.gameTime = gameTime;
    [self simulateTicks];
}

@end
