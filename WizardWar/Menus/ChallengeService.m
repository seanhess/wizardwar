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
//        instance.updated = [RACSubject subject];
        [instance connect];
    });
    return instance;
}

- (void)connect {
    self.entityName = @"Challenge";

    self.node = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/challenges2"];

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
    Challenge * challenge = [self challengeForName:snapshot.name];
    [challenge setValuesForKeysWithDictionary:snapshot.value];

    // performance bottleneck?
    challenge.main = [UserService.shared userWithId:challenge.mainId];
    challenge.opponent = [UserService.shared userWithId:challenge.opponentId];
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    Challenge * challenge = [self challengeForName:snapshot.name];
    if (challenge)
        [ObjectStore.shared.context deleteObject:challenge];    
}

- (Challenge*)challengeForName:(NSString*)firebaseNodeName {
    NSManagedObjectID * objectId = [ObjectStore.shared objectIdForURI:[self objectIdFromFirebaseName:firebaseNodeName]];
    return [ObjectStore.shared objectWithId:objectId create:YES];
}

- (Challenge*)user:(User*)user challengeOpponent:(User*)opponent isRemote:(BOOL)isRemote {
    
    Challenge * challenge = [ObjectStore.shared insertNewObjectForEntityForName:self.entityName];
    challenge.main = user;
    challenge.opponent = opponent;
    
    NSString * name = [self firebaseNameFromObjectId:challenge.objectID];
    Firebase * child = [self.node childByAppendingPath:name];
    [child onDisconnectRemoveValue];
    [child setValue:challenge.toObject];
    
//    if (isRemote) {
//        [self notifyOpponent:challenge];
//    }
    
    return challenge;
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
    request.predicate = [NSPredicate predicateWithFormat:@"main = %@", user];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"main.name" ascending:YES]];
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
