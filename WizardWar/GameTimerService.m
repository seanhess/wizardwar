//
//  GameTimerService.m
//  WizardWar
//
//  Created by Sean Hess on 5/27/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "GameTimerService.h"
#import "FirebaseCollection.h"
#import "PlayerTime.h"
#import "NSArray+Functional.h"

#define DELAY_START 1
#define MAX_TOLERANCE 0.01

@interface GameTimerService ()
@property (strong, nonatomic) Firebase * node;
@property (strong, nonatomic) NSMutableDictionary * times;
@property (strong, nonatomic) FirebaseCollection * timesCollection;
@property (strong, nonatomic) PlayerTime * myTime;
@property (strong, nonatomic) Player * player;
@property (nonatomic) NSInteger currentTick;
@property (nonatomic) NSTimeInterval nextTickTime;
@property (nonatomic) BOOL isHost;
@end

@implementation GameTimerService

-(id)initWithMatchNode:(Firebase *)matchNode player:(Player *)player isHost:(BOOL)isHost {
    self = [super init];
    if (self) {
        self.player = player;
        self.isHost = isHost;
        self.node = [matchNode childByAppendingPath:@"times"];
        
        // both players add themselves
        self.times = [NSMutableDictionary dictionary];
        self.timesCollection = [[FirebaseCollection alloc] initWithNode:self.node dictionary:self.times type:[PlayerTime class]];
        
        // you'll get the other guy here, not in update
        __weak GameTimerService * wself = self;
        [self.timesCollection didAddChild:^(PlayerTime * time) {
            NSLog(@"Timer added %@ %i", time, isHost);
            NSTimeInterval currentTime = CACurrentMediaTime();
            if (isHost && time != self.myTime) {
                NSLog(@"ICH BIN HOST");
                [wself sendEstimate:time currentTime:currentTime];
            }
        }];
        
        [self.timesCollection didUpdateChild:^(PlayerTime * time) {
            NSTimeInterval currentTime = CACurrentMediaTime();
            if (time == self.myTime && time.accepted) {
                NSLog(@"(OTHER) ACCEPTED my time! %f", time.currentTime);
                [self startWithPlayerTime:time];
            }
            else if (time != self.myTime && !time.accepted) {
                if ([wself checkEstimate:time currentTime:currentTime]) {
                    NSLog(@"(ME) ACCEPTING their time! %f", time.currentTime);
                    [wself acceptTime:time];
                    [self startWithPlayerTime:time];
                }
                else {
                    [wself sendEstimate:time currentTime:currentTime];
                }
            }
            
        }];
        
    }
    return self;
}

- (void)sync {
    PlayerTime *myTime = [PlayerTime new];
    myTime.name = self.player.name;
    myTime.currentTime = CACurrentMediaTime();
    self.myTime = myTime;
    [self.timesCollection addObject:myTime withName:myTime.name];
}

- (void)sendEstimate:(PlayerTime*)other currentTime:(NSTimeInterval)currentTime {
    // you record the ACTUAL time different between their clock and yours
    self.myTime.dTimeTo = currentTime - other.currentTime;
    self.myTime.currentTime = currentTime;
    
    // now, set the time you estimate they are ahead of you to dTimeFrom
    // we use the measured time from the last pass
    // LATER: average it?
    if (other.dTimeTo)
        self.myTime.dTimeFrom = other.dTimeTo;
    
    NSLog(@" - sending");
    
    [self.timesCollection updateObject:self.myTime];
}

- (BOOL)checkEstimate:(PlayerTime*)other currentTime:(NSTimeInterval)currentTime {
    NSTimeInterval localTimeOfOther = other.currentTime + other.dTimeFrom;
    NSLog(@"EEE me=%f them=%f local=%f diff=%f", currentTime, other.currentTime, localTimeOfOther, currentTime - localTimeOfOther);
    return (fabs(currentTime - localTimeOfOther) < MAX_TOLERANCE);
}

- (void)acceptTime:(PlayerTime*)other {
    other.accepted = YES;
    [self.timesCollection updateObject:other];
}

// ok, he accepted, it was accurate, so start 1 true second from that time
- (void)startWithPlayerTime:(PlayerTime*)time {
    NSTimeInterval startTime = time.currentTime + DELAY_START;
    if (time != self.myTime) {
        startTime += time.dTimeFrom;
    }
//    NSLog(@"SHOULD START currentTime=%f startTime=%f diff=%f", CACurrentMediaTime(), startTime, );
    [self.delegate gameShouldStartAt:startTime];
}

- (void)startAt:(NSTimeInterval)startTime {
    self.nextTickTime = startTime;
}

// make sure you start calling this by the time you call startAt
- (void)update:(NSTimeInterval)dt {
    if (!self.nextTickTime) return;
    NSTimeInterval currentTime = CACurrentMediaTime();
    if (self.nextTickTime < currentTime) {
        self.nextTickTime = self.nextTickTime + self.tickInterval;
        
        self.currentTick = self.nextTick;
        [self.delegate gameDidTick:self.currentTick];
    }
}

- (void)start {
    NSLog(@"START");
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
