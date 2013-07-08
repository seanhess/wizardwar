//
//  LocalPartyService.m
//  WizardWar
//
//  Created by Sean Hess on 6/1/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "LobbyService.h"
#import "FirebaseCollection.h"
#import "User.h"
#import "IdService.h"
#import "NSArray+Functional.h"
#import "LocationService.h"
#import "UserService.h"

// Just implement global people for this yo
@interface LobbyService ()
@property (nonatomic, strong) Firebase * lobby;
@property (nonatomic, strong) User * currentUser;
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
    
//    if (!self.currentUser) {
//        NSLog(@"LobbyService: SKIP - wait until join lobby");
//        return;
//    }
    
    NSLog(@"CONNECT LobbyService");
    
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


// Guaranteed: that we have currentLocation at this point
-(void)onAdded:(FDataSnapshot *)snapshot {
    User * user = [UserService.shared userWithId:snapshot.name create:YES];
    [user setValuesForKeysWithDictionary:snapshot.value];
    user.isOnline = YES;
    user.distance = [LocationService.shared distanceFrom:user.location];    
    NSLog(@"LOBBY (+) name=%@ distance=%f", user.name, user.distance);
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    User * removed = [UserService.shared userWithId:snapshot.name];
    if (removed) {
        NSLog(@"LOBBY (-) %@", removed.name);
        removed.isOnline = NO;
        removed.locationLatitude = 0;
        removed.locationLongitude = 0;
    }
}

-(void)onChanged:(FDataSnapshot*)snapshot {
    [self onAdded:snapshot];
}

//-(BOOL)userIsLocal:(User*)user {
//    CLLocationDistance distance = [user.location distanceFromLocation:self.currentLocation];
//    NSLog(@"OTHER USER %@ %f", user.name, distance);
//    return (distance < MAX_SAME_LOCATION_DISTANCE);
//}


// Joins us to the lobby, por favor!
// MAKE SURE that the location is set before doing this!
- (void)joinLobby:(User *)user location:(CLLocation *)location {
    NSLog(@"JOIN LOBBY LocationService %@", user);
    
    self.currentUser = user;
    self.currentLocation = location;
    
    if (!self.lobby) [self connect];
    
    Firebase * node = [self.lobby childByAppendingPath:user.userId];
    [node onDisconnectRemoveValue];
    [node setValue:user.toLobbyObject withCompletionBlock:^(NSError*error) {
        self.joined = YES;
    }];
}

- (void)leaveLobby:(User*)user {
    self.currentUser = nil;
    Firebase * node = [self.lobby childByAppendingPath:user.userId];
    [node removeValue];
}

// Gives you local users or 3 random all users
//- (NSDictionary*)localUsers {
//    // Just take the first couple
//    if (self.closeUsers.count == 0) {
//        NSArray * keys = self.allUsers.allKeys;
//        NSInteger end = MIN(3, keys.count);
//        return [self.allUsers dictionaryWithValuesForKeys:[self.allUsers.allKeys subarrayWithRange:NSMakeRange(0, end)]];
//    }
//    return self.closeUsers;
//}


#pragma mark - Core Data Requests

- (NSFetchRequest*)requestCloseUsers {
    NSFetchRequest * request = [UserService.shared requestOtherOnline];
    NSPredicate * notFriend = [NSCompoundPredicate notPredicateWithSubpredicate:[UserService.shared predicateIsFriend]];
    NSPredicate * isClose = [NSPredicate predicateWithFormat:@"distance < %f", MAX_SAME_LOCATION_DISTANCE];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[isClose, notFriend, request.predicate]];
    return request;
}

@end
