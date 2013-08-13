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
@property (strong, nonatomic) NSMutableDictionary * times;
@property (strong, nonatomic) ClientTime * client;
@property (strong, nonatomic) NSString * name;
@property (nonatomic) BOOL isHost;
@property (nonatomic, strong) GameTimerService * timer;
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

// player: "localTime = t2, offset = dt" (start with 100ms, or something)
// host: modifies player with hostTime
// player: repeat
// host: modifies player with hostTime
// player: repeat
// host: modifies player with accepted = YES, hostTime, startTime
// player: gets accepted message, saves offset, starts game at correct host time

// TODO: use the same updated timer as timer service

// CONSTANTLY modify the sync time?
// every 4 seconds or so?
// modify the canonical offset
// host: tick 0 is at time T1
// host: tick 10 is at time T2
// every 100? too far apart
// every 10? too many sync messages probably

// the client doesn't even need to send its time, it just needs a guess as to where the server is at T0
// and to modify it to be close / to match, right?
// it knows there is latency involved, right? So how could it know?
// well, it has an offset stored
// Player: receives Tick 0 at Time 1234, has offset 2222. localTime + offset = Time? If not, new offset = ...
// well, wait, that doesn't make sense. the new offset isn't the EXACT difference in time
// you have to CONFIRM that they match.
// you have to GUESS THE OTHER person's clock
// you have to guess the HOSTS' clock

// Players: I think Tick 0 time is N
// Host: You are off by N
// Player: I think Tick 10 time is N1
// Host: You are off by N
// etc...

// You can do it based on how far off you are!
// If you are dead on over and over, then you should sync harder and harder.

// Player's always initiate queries.

// [ ] explicitly handle shooting in the future, etc, so that it actually makes sense. Just skip it until the time
// [ ] reset local tick timer to match current offset each time
// [ ] sync every N seconds, where N is related to our current error. If outside acceptable range, do it again immediately
// [ ] Keep the game running baby!
// [ ] only replace if error is LESS THAN your current error

// Added: only if host, reply to player guesses
// Changed: only if client, check guesses and update

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
    [self.node observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [wself onAdded:snapshot];
    }];
    
    [self.node observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        [wself onChanged:snapshot];
    }];
    
    if (!isHost) {
        NSAssert((self.client == nil), @"myTime was not cleared!");
        ClientTime *client = [ClientTime new];
        client.name = self.name;
        client.time = self.timer.localTime;
//        client.offset = 0.100; // I think the server will get this in 100ms
        // why do I even have to say what I think the diff is?
        // hmm.
        // ok, "I guess" that the current time is exactly the same
        // the delay is 100ms
        // localTime = 0
        // offset = 0
        // server has to say EXACTLY what time it was when it got the message
        // well, umm.. yeah, that's easy. It's the error + your time
        // I have to remember when I SENT the message (yeah, at time = 0!)
        
        // This method doesn't even freaking work!
        // no wonder I'm confused.
        // I was just guessing the PING time
        // so if it ever changed, I was screwed
        
        // You can't guess once.
        // I don't know the server time
        // I guess what it is NOW
        // I send the guess
        // ..... ?
        // How does the server evaluate this?
        // I say, you were exactly right! The server time IS N when I got this!
        // but that doesn't help, because we don't know how long it took
        
        // All we can do is guess at the round trip time.
        // at least we can measure half of it, right?
        // error = X
        
        // That means that...
        // When LOCAL thinks T0 = 0
        // (sends to server)
        // HOST is thinking... error + delay
        
        // How would this work as a server?
        // the server would tell me what is going on at each tick (it already does)
        // the problem is simulating it
        
        // client should just follow the host
        // I can estimate host time
        // I can estimate round trip time
        // how can I estimate time diff?
        
        // CLIENT: joins second, gets player added early
        // HOST: gets player added late
        
        // absolute times
        // CLIENT T0 = 10
        // HOST T0 = 15
        
        // assuming 100ms delay
        // CLIENT T0 = 0 (local)
        // HOST T0 = 0 (local)
        
        // Base timer on how long it takes to get differences
        // I've already started. CurrentTick = N
        // I cast fireball
        // HOST: casts fireball, arrives far in past
        // we either have large latency, or timers are off
        // IN FUTURE: our timers are definitely off
        
        // The only thing I can REALLY know is
        // - RTT
        // - 
        
        self.client = client;
        [self save:self.client];        
    }
}

// This only matters if you are the host. you don't add your own as a host
- (void)onAdded:(FDataSnapshot*)snapshot {
    if (self.isHost) {
        ClientTime * time = [ClientTime new];
        [time setValuesForKeysWithDictionary:snapshot.value];
        [self hostCheckTime:time];
    }    
}

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

- (void)hostCheckTime:(ClientTime*)client {
    NSTimeInterval error = self.timer.localTime - client.time;
    client.error = error;
    [self save:client];
}

//- (BOOL)isMine:(FDataSnapshot*)snapshot {
//    return [snapshot.name isEqualToString:self.name];
//}

- (void)save:(ClientTime*)time {
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
    self.client = nil;
    self.currentMatchId = nil;
    [self.node removeValue];
    self.node = nil;
    self.name = nil;
}
@end
