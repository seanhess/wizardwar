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

#define DELAY_START 1
#define MAX_TOLERANCE 0.01

@interface TimerSyncService ()
@property (strong, nonatomic) NSString * currentMatchId;
@property (strong, nonatomic) Firebase * node;
@property (strong, nonatomic) NSMutableDictionary * times;
@property (strong, nonatomic) NSString * name;
@property (nonatomic, strong) GameTimerService * timer;

@property (nonatomic) BOOL isHost;
@property (nonatomic) NSTimeInterval requestStartTime;
@end


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
    
    if (self.currentMatchId) {
        NSLog(@"!!! Attempted to connect to match=%@ while still connected to %@", matchId, self.currentMatchId);
        NSAssert(false, @"Connected to more than one match at a time. Remember to call disconnect!");
    }
    
    self.currentMatchId = matchId;
    NSLog(@"TIMER SYNC SERVICE start: matchId=%@ isHost=%i", matchId, isHost);
    
    self.timer = timer;
    self.isHost = isHost;
    self.name = [NSString stringWithFormat:@"%@ %@", player.name, [IdService randomId:4]];
    
    Firebase * matchNode = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wizardwar.firebaseio.com/match/%@", matchId]];
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
        [self sendTimeRequest];        
    }    
}

- (void)sendTimeRequest {
    self.requestStartTime = CACurrentMediaTime();
    GameTime *gameTime = [GameTime new];
    gameTime.name = self.name;
    NSLog(@"TSS request %@", gameTime);
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
    
    GameTime * gameTime = [GameTime new];
    [gameTime setValuesForKeysWithDictionary:snapshot.value];
    
    // convert into local game time
    
    GameTime * adjustedGameTime = [GameTime new];
    adjustedGameTime.name = self.name;
    adjustedGameTime.nextTick = gameTime.nextTick;
    adjustedGameTime.gameTime = gameTime.gameTime + roundTripTime/2;
    adjustedGameTime.nextTickTime = gameTime.nextTickTime;
    
    NSLog(@"TSS got rtt=%f %@", roundTripTime, adjustedGameTime);
    [self.timer updateFromRemoteTime:adjustedGameTime];
    
    // If gameTime > nextTickTime we need to jump / simulate the next tick immediately?
    // Naw, nothing will happen
}

- (void)save:(GameTime*)time {
    Firebase * mynode = [self.node childByAppendingPath:time.name];
    [mynode onDisconnectRemoveValue];
    [mynode setValue:time.toObject];
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
    self.currentMatchId = nil;
    [self.node removeValue];
    self.node = nil;
    self.name = nil;
}
@end
