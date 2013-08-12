//
//  TimerSyncService.m
//  WizardWar
//
//  Created by Sean Hess on 5/29/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "TimerSyncService.h"
#import <Firebase/Firebase.h>
#import "PlayerTime.h"
#import "FirebaseCollection.h"
#import "IdService.h"
#import "cocos2d.h"

#define DELAY_START 1
#define MAX_TOLERANCE 0.01

@interface TimerSyncService ()
@property (strong, nonatomic) NSString * currentMatchId;
@property (strong, nonatomic) Firebase * node;
@property (strong, nonatomic) NSMutableDictionary * times;
@property (strong, nonatomic) PlayerTime * myTime;
@property (strong, nonatomic) PlayerTime * otherTime;
@property (strong, nonatomic) NSString * name;
@property (nonatomic) BOOL isHost;

@property (nonatomic) CGFloat currentTime;
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

- (void)update:(NSTimeInterval)delta {
    self.currentTime += delta;
}

- (void)syncTimerWithMatchId:(NSString *)matchId player:(Wizard *)player isHost:(BOOL)isHost {
    
    if (self.currentMatchId) {
        NSLog(@"!!! Attempted to connect to match=%@ while still connected to %@", matchId, self.currentMatchId);
        NSAssert(false, @"Connected to more than one match at a time. Remember to call disconnect!");
    }
    
    self.currentMatchId = matchId;
    NSLog(@"TIMER SYNC SERVICE start: matchId=%@ isHost=%i", matchId, isHost);
    
    self.isHost = isHost;
    self.name = [NSString stringWithFormat:@"%@ %@", player.name, [IdService randomId:4]];
    
    Firebase * matchNode = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wizardwar.firebaseio.com/match/%@", matchId]];
    self.node = [matchNode childByAppendingPath:@"times"];
    
    // you'll get the other guy here, not in update
    __weak TimerSyncService * wself = self;
    [self.node observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [wself onAdded:snapshot];
    }];
    
    [self.node observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        [wself onChanged:snapshot];
    }];
    
    PlayerTime *myTime = [PlayerTime new];
    myTime.name = self.name;
    myTime.currentTime = self.currentTime;
    NSAssert((self.myTime == nil), @"myTime was not cleared!");
    self.myTime = myTime;
    [self save:myTime];
}

- (void)onAdded:(FDataSnapshot*)snapshot {
    // If it is the other
    
    if (self.isHost) {
        NSLog(@"TSS onAdded isHost");
    }
    
    if (![self isMine:snapshot] && !self.otherTime) {
        NSLog(@"TSS added: %@", snapshot.name);
        PlayerTime * time = [PlayerTime new];
        [time setValuesForKeysWithDictionary:snapshot.value];
        self.otherTime = time;
        
        // host kicks off the message passing
        if (self.isHost) {
            NSLog(@"TSS Host Kickoff");
            [self sendEstimate:time currentTime:self.currentTime];
        }
    }

}

- (void)onChanged:(FDataSnapshot*)snapshot {
    
    // This should NOT be called until we have other time
    
    BOOL isMine = [self isMine:snapshot];
    PlayerTime * time = (isMine) ? self.myTime : self.otherTime;
    [time setValuesForKeysWithDictionary:snapshot.value];
    
    if (isMine && time.accepted) {
        NSLog(@"TSS accepted (OTHER)");
        [self startWithPlayerTime:time];
    }
    else if (!isMine && !time.accepted) {
        NSAssert(self.otherTime, @"Other time not set");
        if ([self checkEstimate:time currentTime:self.currentTime]) {
            NSLog(@"TSS accept (SELF)");
            [self acceptTime:time];
            [self startWithPlayerTime:time];
        }
        else {
            [self sendEstimate:time currentTime:self.currentTime];
        }
    }
    
}

- (BOOL)isMine:(FDataSnapshot*)snapshot {
    return [snapshot.name isEqualToString:self.name];
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
    
//    NSLog(@"TSS send myTime=%f from=%f", self.myTime.currentTime, self.myTime.dTimeFrom);
    
    [self save:self.myTime];
}

- (void)save:(PlayerTime*)time {
    Firebase * mynode = [self.node childByAppendingPath:time.name];
    [mynode onDisconnectRemoveValue];
    [mynode setValue:time.toObject];
}

- (BOOL)checkEstimate:(PlayerTime*)other currentTime:(NSTimeInterval)currentTime {
    NSTimeInterval localTimeOfOther = other.currentTime + other.dTimeFrom;
    CGFloat diff = fabs(currentTime - localTimeOfOther);
//    NSLog(@"TSS check (them=%f + from=%f) diff=%f", other.currentTime, other.dTimeFrom, diff);
    return (diff < MAX_TOLERANCE);
}

- (void)acceptTime:(PlayerTime*)other {
    other.accepted = YES;
    [self save:other];
}

// ok, he accepted, it was accurate, so start 1 true second from that time
- (void)startWithPlayerTime:(PlayerTime*)time {
    NSTimeInterval startTime = time.currentTime + DELAY_START;
    if (time != self.myTime) {
        startTime += time.dTimeFrom;
    }
    NSLog(@"TSS START dTimeFrom=%f", time.dTimeFrom);
    [self.delegate gameShouldStartAt:startTime];
}

- (void)disconnect {
    self.myTime = nil;
    self.otherTime = nil;    
    self.currentMatchId = nil;
    [self.node removeValue];
    self.node = nil;
    self.name = nil;
}
@end
