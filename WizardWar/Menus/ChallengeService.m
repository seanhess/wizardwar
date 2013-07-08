//
//  ChallengeService.m
//  WizardWar
//
//  Created by Sean Hess on 6/21/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "ChallengeService.h"
#import <Firebase/Firebase.h>
#import "Challenge.h"
#import "UserService.h"
#import "LobbyService.h"
#import <Parse/Parse.h>

@interface ChallengeService ()
@property (nonatomic) BOOL connected;
@property (nonatomic, strong) Firebase * node;
@end

@implementation ChallengeService

+ (ChallengeService *)shared {
    static ChallengeService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ChallengeService alloc] init];
        instance.updated = [RACSubject subject];
    });
    return instance;
}

- (void)connect {
    if (self.connected) return;
    self.connected = YES;
    
    NSLog(@"CONNECT ChallengeService");
    
    self.node = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/challenges"];
    self.myChallenges = [NSMutableDictionary dictionary];
    
    __weak ChallengeService * wself = self;
    
    [self.node observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [wself onAdded:snapshot];
    }];
    
    [self.node observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        [wself onRemoved:snapshot];
    }];
}

// I only care about challenges involving ME
-(void)onAdded:(FDataSnapshot *)snapshot {
    
    Challenge * challenge = [Challenge new];
    [challenge setValuesForKeysWithDictionary:snapshot.value];
    
    if ([challenge.mainId isEqualToString:UserService.shared.currentUser.userId] || [challenge.opponentId isEqualToString:UserService.shared.currentUser.userId]) {
        
        challenge.main = [UserService.shared userWithId:challenge.mainId];
        challenge.opponent = [UserService.shared userWithId:challenge.opponentId];
        
        self.myChallenges[challenge.matchId] = challenge;
        [self.updated sendNext:challenge];
    }
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    Challenge * challenge = self.myChallenges[snapshot.name];
    if (challenge) {
        [self.myChallenges removeObjectForKey:snapshot.name];
        [self.updated sendNext:challenge];
    }
}

- (Challenge*)user:(User*)user challengeOpponent:(User*)opponent isRemote:(BOOL)isRemote {
    Challenge * challenge = [Challenge new];
    challenge.main = user;
    challenge.opponent = opponent;
    
    Firebase * child = [self.node childByAppendingPath:challenge.matchId];
    [child onDisconnectRemoveValue];
    [child setValue:challenge.toObject];
    
    if (isRemote) {
        [self notifyOpponent:challenge];
    }
    
    return challenge;
}

- (void)notifyOpponent:(Challenge*)challenge {
    
    if (!challenge.opponent.deviceToken) {
        NSLog(@"CANNOT PUSH! no device token");
        return;
    }
    
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
    [pushQuery whereKey:@"deviceToken" equalTo:challenge.opponent.deviceToken];
    
    // Send push notification to query
    [PFPush sendPushDataToQueryInBackground:pushQuery withData:@{
        @"alert":[NSString stringWithFormat:@"%@ challenges you to WAR", challenge.main.name],
        @"matchId":challenge.matchId
    }];
}


@end
