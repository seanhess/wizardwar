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
#import "ObjectStore.h"

@interface ChallengeService ()
@property (nonatomic) BOOL connected;
@property (nonatomic, strong) Firebase * node;
@property (nonatomic, strong) NSString * entityName;
@end

@implementation ChallengeService

+ (ChallengeService *)shared {
    static ChallengeService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ChallengeService alloc] init];
        instance.entityName = @"Challenge";
    });
    return instance;
}

- (void)connectAndReset {

    [self removeAll];

    self.node = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/challenges2"];

    __weak ChallengeService * wself = self;
    [self.node observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [wself onAdded:snapshot];
    }];
    
    [self.node observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        [wself onRemoved:snapshot];
    }];
    
    [self.node observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        [wself onChanged:snapshot];
    }];
}

-(void)removeAll {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    [ObjectStore.shared requestRemove:request];
}

-(void)onAdded:(FDataSnapshot *)snapshot {
    // Assumes the users have already been loaded
    User * main = [UserService.shared userWithId:snapshot.name];
    Challenge * challenge = [self createOrFindChallengeForUser:main];
    [challenge setValuesForKeysWithDictionary:snapshot.value];
    
    challenge.main = main;
    challenge.opponent = [UserService.shared userWithId:challenge.opponentId];
    
    NSLog(@"ChallengeService (+) %@ vs %@", challenge.main.name, challenge.opponent.name);
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    User * main = [UserService.shared userWithId:snapshot.name];
    Challenge * challenge = main.challenge;
    if (challenge) {
        NSLog(@"ChallengeService (-) %@ vs %@", challenge.main.name, challenge.opponent.name);        
        [ObjectStore.shared.context deleteObject:challenge];
    }
}

-(void)onChanged:(FDataSnapshot*)snapshot {
    [self onAdded:snapshot];
}

- (void)acceptChallenge:(Challenge*)challenge {
    challenge.status = ChallengeStatusAccepted;
    
    Firebase * child = [self challengeNode:challenge];
    [child onDisconnectRemoveValue];
    [child setValue:challenge.toObject];    
}

- (Firebase*)challengeNode:(Challenge*)challenge {
    Firebase * child = [self.node childByAppendingPath:challenge.main.userId];
    return child;
}

- (Challenge*)createOrFindChallengeForUser:(User*)user {
    Challenge * challenge = user.challenge;
    if (!challenge) {
        challenge = [ObjectStore.shared insertNewObjectForEntityForName:self.entityName];
    }
    return challenge;
}

// this is only called from the perspective of the current user
- (Challenge*)user:(User*)user challengeOpponent:(User*)opponent isRemote:(BOOL)isRemote {
    
    Challenge * challenge = [self createOrFindChallengeForUser:user];
    challenge.main = user;
    challenge.opponent = opponent;
    challenge.status = ChallengeStatusPending;
    
    Firebase * child = [self challengeNode:challenge];
    [child onDisconnectRemoveValue];
    [child setValue:challenge.toObject];
    
//    if (isRemote) {
//        [self notifyOpponent:challenge];
//    }
    
    return challenge;
}

- (void)removeChallenge:(Challenge*)challenge {
    Firebase * child = [self challengeNode:challenge];
    [child removeValue];
}

- (NSFetchRequest*)requestChallengesForUser:(User*)user {
    // valid users include:
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"main.userId = %@ OR opponent.userId = %@", user.userId, user.userId];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"main.userId" ascending:YES]];
    return request;
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
