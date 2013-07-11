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
#import "NSArray+Functional.h"
#import "IdService.h"

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
        instance.acceptedSignal = [RACSubject subject];
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
    Challenge * challenge = [self challengeWithId:snapshot.name create:YES];
    [challenge setValuesForKeysWithDictionary:snapshot.value];
    
//    User * main = [UserService.shared userWithId:snapshot.name];
//    Challenge * challenge = [self createOrFindChallengeForUser:main];

    challenge.main = [UserService.shared userWithId:challenge.mainId];
    challenge.opponent = [UserService.shared userWithId:challenge.opponentId];
    
    NSLog(@"ChallengeService (+) %@ vs %@", challenge.main.name, challenge.opponent.name);
    
    // we have a new accepted match!
    if (challenge.status == ChallengeStatusAccepted) {
        [self.acceptedSignal sendNext:challenge];
    }
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    Challenge * challenge = [self challengeWithId:snapshot.name create:NO];
    if (challenge) {
        NSLog(@"ChallengeService (-) %@ vs %@", challenge.main.name, challenge.opponent.name);        
        [ObjectStore.shared.context deleteObject:challenge];
    }
}

-(void)onChanged:(FDataSnapshot*)snapshot {
    [self onAdded:snapshot];
}


- (BOOL)challenge:(Challenge*)challenge isCreatedByUser:(User*)user {
    return [challenge.main.userId isEqualToString:user.userId];
}




- (void)acceptChallenge:(Challenge*)challenge {
    [self setChallenge:challenge status:ChallengeStatusAccepted];
}

- (void)declineChallenge:(Challenge*)challenge {
    [self setChallenge:challenge status:ChallengeStatusDeclined];
}




- (Firebase*)challengeNode:(Challenge*)challenge {
    return [self.node childByAppendingPath:challenge.matchId];
}



- (void)setChallenge:(Challenge*)challenge status:(ChallengeStatus)status {
    challenge.status = status;
    Firebase * child = [self challengeNode:challenge];
    [child onDisconnectRemoveValue];
    [child setValue:challenge.toObject];
}


- (Challenge*)challengeWithId:(NSString*)matchId create:(BOOL)create {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"matchId = %@", matchId];
    Challenge * challenge = [ObjectStore.shared requestLastObject:request];
    if (!challenge && create) {
        challenge = [ObjectStore.shared insertNewObjectForEntityForName:self.entityName];
        challenge.matchId = matchId;
    }
    return challenge;
}

- (Challenge*)createOrFindChallengeForUser:(User*)user {
    if (user.challenge) {
        return user.challenge;
    }
    else {
        Challenge * challenge = [ObjectStore.shared insertNewObjectForEntityForName:self.entityName];
        challenge.matchId = [IdService randomId:5];
        return challenge;
    }
}

// this is only called from the perspective of the current user
// Need to get the same one for the given user
- (Challenge*)user:(User*)user challengeOpponent:(User*)opponent isRemote:(BOOL)isRemote {
    Challenge * challenge = [self createOrFindChallengeForUser:user];
    challenge.main = user;
    challenge.opponent = opponent;
    challenge.status = ChallengeStatusPending;
    
    Firebase * child = [self challengeNode:challenge];
    [child onDisconnectRemoveValue];
    [child setValue:challenge.toObject];
    
    if (isRemote) {
        [self notifyOpponent:challenge];
    }
    
    return challenge;
}

- (void)removeChallenge:(Challenge*)challenge {
    Firebase * child = [self challengeNode:challenge];
    [child removeValue];
}

- (void)removeUserChallenge:(User *)user {
    // if I have a challenge, remove it!
    if (user.challenge) {
        [ChallengeService.shared removeChallenge:user.challenge];
    }
}

- (void)declineAllChallenges:(User *)user {
    // set all targeted ones to declined
    NSArray * challenges = [ObjectStore.shared requestToArray:[self requestChallengesTargetingUser:user]];
    [challenges forEach:^(Challenge*challenge) {
        [self declineChallenge:challenge];
    }];
}



#pragma mark - CoreData

- (NSPredicate*)predicateUserIsMain:(User *)user {
    return [NSPredicate predicateWithFormat:@"main.userId = %@", user.userId];
}

- (NSPredicate*)predicateUserIsTargeted:(User *)user {
    NSPredicate * notDeclined = [NSPredicate predicateWithFormat:@"status != %i", ChallengeStatusDeclined];
    NSPredicate * userIsOpponent = [NSPredicate predicateWithFormat:@"opponent.userId = %@", user.userId];
    NSPredicate * showOpponent = [NSCompoundPredicate andPredicateWithSubpredicates:@[userIsOpponent, notDeclined]];
    return showOpponent;
}


- (NSFetchRequest*)requestChallengesForUser:(User*)user {
    // valid users include:
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    NSPredicate * userIsMain = [self predicateUserIsMain:user];
    NSPredicate * userTargeted = [self predicateUserIsTargeted:user];
    request.predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[userIsMain, userTargeted]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"main.userId" ascending:YES]];
    return request;
}

- (NSFetchRequest*)requestChallengesTargetingUser:(User*)user {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    request.predicate = [self predicateUserIsTargeted:user];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"main.userId" ascending:YES]];
    return request;    
}

- (Challenge*)user:(User *)user challengedByOpponent:(User *)opponent {
    NSArray * challenges = [ObjectStore.shared requestToArray:[self requestChallengesTargetingUser:user]];
    return [challenges find:^BOOL(Challenge*challenge) {
        BOOL userIsOpponent = [challenge.opponent.userId isEqualToString:user.userId];
        BOOL opponentMatches = [challenge.main.userId isEqualToString:opponent.userId];
        return userIsOpponent && opponentMatches;
    }];
}



# pragma mark - Push Notifications

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
