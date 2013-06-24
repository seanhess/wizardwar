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

// Just implement global people for this yo
@interface LobbyService ()
@property (nonatomic, strong) Firebase * lobby;
@property (nonatomic, strong) User * currentUser;
@property (nonatomic, strong) CLLocation * currentLocation;
@property (nonatomic, strong) NSMutableDictionary * allUsers;
@property (nonatomic, strong) NSMutableDictionary * closeUsers;
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
    
    if (!self.currentUser) {
        NSLog(@"LobbyService: SKIP - wait until join lobby");
        return;
    }
    
    NSLog(@"CONNECT LobbyService");
    
    // The LOBBY contains a list of users currently active in the game
    self.closeUsers = [NSMutableDictionary dictionary];
    self.allUsers = [NSMutableDictionary dictionary];
    self.lobby = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/lobby"];
    
    __weak LobbyService * wself = self;

    [self.lobby observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [wself onAdded:snapshot];
    }];
    
    [self.lobby observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        [wself onRemoved:snapshot];
    }];
    
//    [self.lobby observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
//        [wself onChanged:snapshot];
//    }];
}

-(void)onAdded:(FDataSnapshot *)snapshot {
    User * user = [User new];
    [user setValuesForKeysWithDictionary:snapshot.value];
    if ([user.name isEqualToString:self.currentUser.name]) {
        self.joined = YES;
    }
    
    else {
        self.allUsers[snapshot.name] = user;
        
        if ([self isLocal:user]) {
            NSLog(@" - close");
            self.closeUsers[snapshot.name] = user;
        }
        else {
            NSLog(@" - far");
        }
    
        [self.updated sendNext:user];
    }
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    User * removed = self.allUsers[snapshot.name];
    if (removed) {
        [self.allUsers removeObjectForKey:snapshot.name];
        [self.closeUsers removeObjectForKey:snapshot.name];
        [self.updated sendNext:removed];
    }
}

-(void)onChanged:(FDataSnapshot*)snapshot {
//    if (self.closeUsers[snapshot.name]) {
//        
//    }
}

-(BOOL)isLocal:(User*)user {
    CLLocationDistance distance = [user.location distanceFromLocation:self.currentLocation];
    NSLog(@"OTHER USER %@ %f", user.name, distance);
    return (distance < MAX_SAME_LOCATION_DISTANCE);
}


// Joins us to the lobby, por favor!
// MAKE SURE that the location is set before doing this!
- (void)joinLobby:(User *)user location:(CLLocation *)location {
    NSLog(@"JOIN LOBBY LocationService %@", user);
    
    self.currentUser = user;
    self.currentLocation = location;
    
    if (!self.lobby) [self connect];
    
    Firebase * node = [self.lobby childByAppendingPath:user.userId];
    [node onDisconnectRemoveValue];
    [node setValue:user.toObject];
    
}

- (void)leaveLobby:(User*)user {
    self.currentUser = nil;
    Firebase * node = [self.lobby childByAppendingPath:user.userId];
    [node removeValue];
}

- (User*)userWithId:(NSString*)userId {
    if ([userId isEqualToString:self.currentUser.userId])
         return self.currentUser;
    
    return [self.allUsers objectForKey:userId];
}

- (BOOL)userIsOnline:(User*)user {
    return ([self.allUsers objectForKey:user.userId] != nil);
}

// Gives you local users or 3 random all users
- (NSDictionary*)localUsers {
    // Just take the first couple
    if (self.closeUsers.count == 0) {
        NSArray * keys = self.allUsers.allKeys;
        NSInteger end = MIN(3, keys.count);
        return [self.allUsers dictionaryWithValuesForKeys:[self.allUsers.allKeys subarrayWithRange:NSMakeRange(0, end)]];
    }
    return self.closeUsers;
}

@end
