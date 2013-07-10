//
//  LocalPartyService.m
//  WizardWar
//
//  Created by Sean Hess on 6/1/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "LobbyService.h"
#import "User.h"
#import "IdService.h"
#import "NSArray+Functional.h"
#import "LocationService.h"
#import "UserService.h"
#import "ObjectStore.h"
#import <Firebase/Firebase.h>

// Just implement global people for this yo
@interface LobbyService ()
@property (nonatomic, strong) Firebase * lobby;
@property (nonatomic, strong) CLLocation * currentLocation;
@end

// Use location is central to LOBBY

@implementation LobbyService

+ (LobbyService *)shared {
    static LobbyService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LobbyService alloc] init];
        instance.updated = [RACSubject subject];
        instance.joined = NO;
        
    });
    return instance;
}

// I don't really want to connect until I have MY location
// so I don't get the updates too early
- (void)connect {
    
    [self setAllOffline];
    
    self.lobby = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/lobby"];
    
    __weak LobbyService * wself = self;

    [self.lobby observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [wself onAdded:snapshot];
    }];
    
    [self.lobby observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        [wself onRemoved:snapshot];
    }];
    
    [self.lobby observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        [wself onChanged:snapshot];
    }];
}

// change all users to be offline so we can accurately sync with the server
// ALTERNATIVE: put the field on user itself and have the user change it? naww...
-(void)setAllOffline {
    NSFetchRequest * request = [UserService.shared requestOtherOnline];
    NSArray * users = [ObjectStore.shared requestToArray:request];
    
    [users forEach:^(User * user) {
        user.isOnline = NO;
    }];
}


// Guaranteed: that we have currentLocation at this point
-(void)onAdded:(FDataSnapshot *)snapshot {
    User * user = [UserService.shared userWithId:snapshot.name create:YES];
    [user setValuesForKeysWithDictionary:snapshot.value];
    user.isOnline = YES;
    user.distance = [LocationService.shared distanceFrom:user.location];    
//    NSLog(@"LOBBY (+) name=%@ distance=%f", user.name, user.distance);
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    User * removed = [UserService.shared userWithId:snapshot.name];
    if (removed) {
//        NSLog(@"LOBBY (-) %@", removed.name);
        removed.isOnline = NO;
        removed.locationLatitude = 0;
        removed.locationLongitude = 0;
    }
}

-(void)onChanged:(FDataSnapshot*)snapshot {
    [self onAdded:snapshot];
}

// Joins us to the lobby, por favor!
// MAKE SURE that the location is set before doing this!
- (void)joinLobby:(User *)user location:(CLLocation *)location {
//    NSLog(@"JOIN LOBBY LocationService %@", user);

    self.joined = NO;
    self.currentLocation = location;
    
    [self connect];
    
    Firebase * node = [self.lobby childByAppendingPath:user.userId];
    [node onDisconnectRemoveValue];
    [node setValue:user.toLobbyObject withCompletionBlock:^(NSError *error, Firebase *ref) {
        self.joined = YES;
    }];
}

- (void)leaveLobby:(User*)user {
    self.joined = NO;
    Firebase * node = [self.lobby childByAppendingPath:user.userId];
    [node removeValue];
}

#pragma mark - Core Data Requests

// Local users can come even without a device token
// If they have no device token
- (NSFetchRequest*)requestCloseUsers {
    NSFetchRequest * request = [UserService.shared requestOtherOnline];
    NSPredicate * notFriend = [NSCompoundPredicate notPredicateWithSubpredicate:[UserService.shared predicateIsFriend]];
    NSPredicate * isClose = [NSPredicate predicateWithFormat:@"distance < %f", MAX_SAME_LOCATION_DISTANCE];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[isClose, notFriend, request.predicate]];
    return request;
}

@end
