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
@property (nonatomic, strong) Challenge * currentChallenge;
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

// I only care about challenges involving ME
-(void)onAdded:(FDataSnapshot *)snapshot {
    Challenge * challenge = [self challengeForName:snapshot.name];
    [challenge setValuesForKeysWithDictionary:snapshot.value];
    
    // performance bottleneck?
    // what if the user doesn't exist yet?
    
    if (!challenge.main)
        challenge.main = [UserService.shared userWithId:challenge.mainId];
    
    if (!challenge.opponent)
        challenge.opponent = [UserService.shared userWithId:challenge.opponentId];
    
    NSLog(@"ChallengeService (+) %@ vs %@", challenge.main.name, challenge.opponent.name);
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    Challenge * challenge = [self challengeForName:snapshot.name];
    if (challenge) {
        NSLog(@"ChallengeService (-) %@ vs %@", challenge.main.name, challenge.opponent.name);        
        [ObjectStore.shared.context deleteObject:challenge];
    }
}

- (Challenge*)challengeForName:(NSString*)firebaseNodeName {
    NSManagedObjectID * objectId = [ObjectStore.shared objectIdForURI:[self objectIdFromFirebaseName:firebaseNodeName]];
    return [ObjectStore.shared objectWithId:objectId create:YES];
}

-(void)onChanged:(FDataSnapshot*)snapshot {
    [self onAdded:snapshot];
}

- (void)acceptChallenge:(Challenge*)challenge {
    challenge.accepted = YES;
    
    NSString * name = [self firebaseNameFromObjectId:challenge.objectID];
    Firebase * child = [self.node childByAppendingPath:name];
    [child onDisconnectRemoveValue];
    [child setValue:challenge.toObject];    
}

// this is only called from the perspective of the current user
- (Challenge*)user:(User*)user challengeOpponent:(User*)opponent isRemote:(BOOL)isRemote {
    
    if (self.currentChallenge) {
        [self removeChallenge:self.currentChallenge];
    }
    
    Challenge * challenge = [ObjectStore.shared insertNewObjectForEntityForName:self.entityName];
    challenge.main = user;
    challenge.opponent = opponent;
    
    self.currentChallenge = challenge;
    
    NSString * name = [self firebaseNameFromObjectId:challenge.objectID];
    Firebase * child = [self.node childByAppendingPath:name];
    [child onDisconnectRemoveValue];
    [child setValue:challenge.toObject];
    
//    if (isRemote) {
//        [self notifyOpponent:challenge];
//    }
    
    return challenge;
}

- (void)removeChallenge:(Challenge*)challenge {
    NSString * name = [self firebaseNameFromObjectId:challenge.objectID];
    Firebase * child = [self.node childByAppendingPath:name];
    [child removeValue];
}

-(NSString*)firebaseNameFromObjectId:(NSManagedObjectID*)objectId {
    return [objectId.URIRepresentation.description stringByReplacingOccurrencesOfString:@"x-coredata:///Challenge/t" withString:@""];
}

-(NSString*)objectIdFromFirebaseName:(NSString*)firebaseName {
    return [NSString stringWithFormat:@"x-coredata:///Challenge/t%@", firebaseName];
}

- (NSFetchRequest*)requestChallengesForUser:(User*)user {
    // valid users include:
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"main.userId = %@", user.userId];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"main" ascending:YES]];
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
