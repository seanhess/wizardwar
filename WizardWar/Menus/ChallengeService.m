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
    });
    return instance;
}

- (void)connect {
    if (self.connected) return;
    self.connected = YES;
    
    self.updated = [RACSubject subject];
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
    
    if ([challenge.main.userId isEqualToString:UserService.shared.currentUser.userId] || [challenge.opponent.userId isEqualToString:UserService.shared.currentUser.userId]) {
        
        challenge.main = [LobbyService.shared userWithId:challenge.main.userId];
        challenge.opponent = [LobbyService.shared userWithId:challenge.opponent.userId];        
        
        self.myChallenges[challenge.matchId] = challenge;
        [self.updated sendNext:self.myChallenges];
    }
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    if (self.myChallenges[snapshot.name]) {
        [self.myChallenges removeObjectForKey:snapshot.name];
        [self.updated sendNext:self.myChallenges];
    }
}

- (void)user:(User*)user challengeOpponent:(User*)opponent {
    Challenge * challenge = [Challenge new];
    challenge.main = user;
    challenge.opponent = opponent;
    
    Firebase * child = [self.node childByAppendingPath:challenge.matchId];
    [child onDisconnectRemoveValue];
    [child setValue:challenge.toObject];
}


@end
