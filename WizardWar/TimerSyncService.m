//
//  TimerSyncService.m
//  WizardWar
//
//  Created by Sean Hess on 5/29/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "TimerSyncService.h"
#import <Firebase/Firebase.h>
#import "ClientTime.h"
#import "FirebaseCollection.h"
#import "IdService.h"
#import "cocos2d.h"

#define DELAY_START 1
#define MAX_TOLERANCE 0.01

@interface TimerSyncService ()
@property (strong, nonatomic) NSString * currentMatchId;
@property (strong, nonatomic) Firebase * node;
@property (strong, nonatomic) NSString * name;
@property (nonatomic) BOOL isHost;
@property (nonatomic, strong) GameTimerService * timer;

@property (nonatomic) NSUInteger serverTime;
@property (nonatomic) NSUInteger startTime;
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
    
    // Connect to my personal node
    Firebase * matchNode = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wizardwar.firebaseio.com/match/%@", matchId]];
    self.node = [[matchNode childByAppendingPath:@"times"] childByAppendingPath:self.name];
    [self getInitialServerTime];
}

- (void)getInitialServerTime {
    NSLog(@"TSS getInitialServerTime");
    __weak TimerSyncService * wself = self;
    [self.node observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {        
        [wself.node removeAllObservers];
        [wself measureRTT:[snapshot.value intValue]];
    }];
    
    [self.node onDisconnectRemoveValue];
    [self.node setValue:kFirebaseServerValueTimestamp];    
}

- (void)measureRTT:(NSUInteger)startTime {
    NSLog(@"Measure RTT %i", startTime);
    [self.node setValue:kFirebaseServerValueTimestamp];
    __weak TimerSyncService * wself = self;
    [self.node observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSUInteger serverTime = [snapshot.value intValue];
        if (serverTime == startTime) return; // you get the same value right at first
        NSUInteger roundTripTime = serverTime - startTime;
        [wself addServerTime:serverTime roundTripTime:roundTripTime];
        [wself.node removeAllObservers];        
    }];
}

- (void)addServerTime:(NSUInteger)serverTime roundTripTime:(NSUInteger)roundTripTime {
    NSLog(@"GOT SERVER TIME %i RTT %i", serverTime, roundTripTime);
}

// Well, this is a bust
// Hae

- (void)onChanged:(FDataSnapshot*)snapshot {    
//    BOOL isMine = [self isMine:snapshot];
//    ClientTime * time = (isMine) ? self.myTime : self.otherTime;
//    [time setValuesForKeysWithDictionary:snapshot.value];
//    
//    if (isMine && time.accepted) {
//        NSLog(@"TSS accepted (OTHER)");
//        [self startWithPlayerTime:time];
//    }
//    else if (!isMine && !time.accepted) {
//        NSAssert(self.otherTime, @"Other time not set");
//        if ([self checkEstimate:time currentTime:self.timer.localTime]) {
//            NSLog(@"TSS accept (SELF)");
//            [self acceptTime:time];
//            [self startWithPlayerTime:time];
//        }
//        else {
//            [self sendEstimate:time currentTime:self.timer.localTime];
//        }
//    }
}

//- (void)hostCheckTime:(ClientTime*)client {
//    NSTimeInterval error = self.timer.gameTime - client.time;
//    client.error = error;
//    [self save:client];
//}

//- (BOOL)isMine:(FDataSnapshot*)snapshot {
//    return [snapshot.name isEqualToString:self.name];
//}

//- (void)save:(ClientTime*)time {
//    Firebase * mynode = [self.node childByAppendingPath:time.name];
//    [mynode onDisconnectRemoveValue];
//    [mynode setValue:time.toObject];
//}

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
//    self.client = nil;
    self.currentMatchId = nil;
    [self.node removeValue];
    self.node = nil;
    self.name = nil;
}
@end
