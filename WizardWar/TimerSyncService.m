//
//  TimerSyncService.m
//  WizardWar
//
//  Created by Sean Hess on 5/29/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "TimerSyncService.h"
#import <Firebase/Firebase.h>
#import "GameTime.h"
#import "FirebaseCollection.h"
#import "IdService.h"
#import "cocos2d.h"

#define SYNC_INTERVAL 2.0
#define MAX_TIME_SHIFT 0.01

@interface TimerSyncService ()
@property (strong, nonatomic) NSString * currentMatchId;
@property (strong, nonatomic) Firebase * node;
@property (strong, nonatomic) NSMutableDictionary * times;
@property (strong, nonatomic) NSString * name;
@property (nonatomic, strong) GameTimerService * timer;

@property (nonatomic) NSTimeInterval averageRoundTripTime;
@property (nonatomic) NSInteger numberOfTimeRequests;

@property (nonatomic) BOOL isHost;
@property (nonatomic) NSTimeInterval requestStartTime;
@end

// Continue to send more of these and see if you can dial in.


@implementation TimerSyncService

+ (TimerSyncService *)shared {
    static TimerSyncService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TimerSyncService alloc] init];
    });
    return instance;
}


- (void)syncTimerWithMatchId:(NSString *)matchId player:(Wizard *)player isHost:(BOOL)isHost timer:(GameTimerService *)timer {
    
    if (!self.root) {
        NSLog(@"!!! Cannot sync without firebase root ref");
        NSAssert(false, @"!!! Cannot sync without firebase root ref");
        return;
    }
    
    if (self.currentMatchId) {
        NSLog(@"!!! Attempted to connect to match=%@ while still connected to %@", matchId, self.currentMatchId);
        NSAssert(false, @"Connected to more than one match at a time. Remember to call disconnect!");
    }
    
    self.currentMatchId = matchId;
    NSLog(@"TIMER SYNC SERVICE start: matchId=%@ isHost=%i", matchId, isHost);
    
    self.timer = timer;
    self.isHost = isHost;
    self.name = [NSString stringWithFormat:@"%@ %@", player.name, [IdService randomId:4]];
    
    Firebase * matchNode = [[self.root childByAppendingPath:@"match"] childByAppendingPath:matchId];
    self.node = [matchNode childByAppendingPath:@"times"];
    
    // you'll get the other guy here, not in update
    __weak TimerSyncService * wself = self;
    
    // hosts listen for new time requests
    if (isHost) {
        [self.node observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
            [wself hostRespondChild:snapshot];
        }];
    }
    
    // clients listen for responses
    else {
        [self.node observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
            [wself clientReceiveRequestUpdate:snapshot];
        }];
        self.numberOfTimeRequests = 0;
        [self sendTimeRequest];        
    }    
}

- (void)sendTimeRequest {
    self.numberOfTimeRequests += 1;
    self.requestStartTime = CACurrentMediaTime();
    GameTime *gameTime = [GameTime new];
    gameTime.name = self.name;
    [self save:gameTime];
}

// This only matters if you are the host. you don't add your own as a host
- (void)hostRespondChild:(FDataSnapshot*)snapshot {
    GameTime * time = [GameTime new];
    [time setValuesForKeysWithDictionary:snapshot.value];
    time.nextTickTime = self.timer.nextTickTime;
    time.nextTick = self.timer.nextTick;
    time.gameTime = self.timer.gameTime;
    NSLog(@"TSS (host) respond %@", time);    
    [self save:time];
}

- (void)clientReceiveRequestUpdate:(FDataSnapshot*)snapshot {
    
    // Measure RTT first
    NSTimeInterval roundTripTime = CACurrentMediaTime() - self.requestStartTime;
    NSTimeInterval localGameTime = self.timer.gameTime;
    self.averageRoundTripTime = [self calculateAverageRoundTripTime:roundTripTime];
    
    GameTime * gameTime = [GameTime new];
    [gameTime setValuesForKeysWithDictionary:snapshot.value];
    
    // You don't want to use the average to calculate. It's more likely to be close to the current round trip time
    // Now, just bump it a little bit, depending on how far off it is?
    NSTimeInterval calculatedGameTime = gameTime.gameTime + roundTripTime/2;
    NSTimeInterval dGameTime = localGameTime - calculatedGameTime;
    
    NSLog(@"TSS got  (%i) RTT(%.3f %.3f) dGameTime(%.3f)", self.numberOfTimeRequests, roundTripTime, self.averageRoundTripTime, dGameTime);

    if (self.numberOfTimeRequests <= 1) {
        // convert into local game time
        GameTime * adjustedGameTime = [GameTime new];
        adjustedGameTime.name = self.name;
        adjustedGameTime.nextTick = gameTime.nextTick;
        adjustedGameTime.gameTime = calculatedGameTime;
        adjustedGameTime.nextTickTime = gameTime.nextTickTime;
        [self.timer startFromRemoteTime:adjustedGameTime];
    }

    else {
        if (dGameTime > MAX_TIME_SHIFT) dGameTime = MAX_TIME_SHIFT;
        else if (dGameTime < -MAX_TIME_SHIFT) dGameTime = -MAX_TIME_SHIFT;
        NSTimeInterval newGameTime = localGameTime + dGameTime;
        [self.timer updateFromRemoteTime:newGameTime];
    }
    
    
    // dGameTime: 0.47, 0.2, 0.04, 0.37, 0.27, 0.02, 0.09
    // a shift of 0.05 will be very noticiable
    // a shift of 0.01 might not be
    
    
    // how different is the calculated game time from the current game time
    
    [self remove:gameTime];
    [self syncAgainAfterDelay:SYNC_INTERVAL];
}

- (void)syncAgainAfterDelay:(NSTimeInterval)delay {
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.node && self.currentMatchId)
            [self sendTimeRequest];
    });
}

- (NSTimeInterval)calculateAverageRoundTripTime:(NSTimeInterval)roundTripTime {
    return (roundTripTime + self.averageRoundTripTime*(self.numberOfTimeRequests-1)) / self.numberOfTimeRequests;
}

- (void)save:(GameTime*)time {
    Firebase * mynode = [self.node childByAppendingPath:time.name];
    [mynode onDisconnectRemoveValue];
    [mynode setValue:time.toObject];
}

- (void)remove:(GameTime*)time {
    Firebase * mynode = [self.node childByAppendingPath:time.name];
    [mynode removeValue];
}

//- (BOOL)checkEstimate:(ClientTime*)other currentTime:(NSTimeInterval)currentTime {
//    NSTimeInterval localTimeOfOther = other.currentTime + other.dTimeFrom;
//    CGFloat diff = fabs(currentTime - localTimeOfOther);
////    NSLog(@"TSS check (them=%f + from=%f) diff=%f", other.currentTime, other.dTimeFrom, diff);
//    return (diff < MAX_TOLERANCE);
//}
//
//- (void)acceptTime:(ClientTime*)other {
//    other.accepted = YES;
//    [self save:other];
//}

// ok, he accepted, it was accurate, so start 1 true second from that time
//- (void)startWithPlayerTime:(ClientTime*)time {
//    NSTimeInterval startTime = time.currentTime + DELAY_START;
//    if (time != self.myTime) {
//        startTime += time.dTimeFrom;
//    }
//    NSLog(@"TSS START dTimeFrom=%f", time.dTimeFrom);
//    [self.delegate gameShouldStartAt:startTime];
//}

- (void)disconnect {
    self.root = nil;
    self.currentMatchId = nil;
    [self.node removeValue];
    [self.node removeAllObservers];
    self.node = nil;
    self.name = nil;
}
@end
