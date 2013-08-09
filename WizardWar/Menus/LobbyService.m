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
#import "ConnectionService.h"
#import <ReactiveCocoa.h>
#import "UserFriendService.h"

// Just implement global people for this yo
@interface LobbyService ()
@property (nonatomic, strong) Firebase * lobby;
@property (nonatomic, strong) CLLocation * currentLocation;
@property (nonatomic, strong) User * joinedUser;
@property (nonatomic) BOOL joining;
@end

// Use location is central to LOBBY

@implementation LobbyService

+ (LobbyService *)shared {
    static LobbyService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LobbyService alloc] init];
        instance.joined = NO;
        instance.joining = NO;
        
    });
    return instance;
}

- (void)connect {
    
    
    NSLog(@"LobbyService: connect");
    [self setAllOffline];
    
    self.lobby = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/lobby"];
    
    __weak LobbyService * wself = self;

    [self.lobby observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        self.totalInLobby++;        
        [wself onAdded:snapshot];
    }];
    
    [self.lobby observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        self.totalInLobby--;
        [wself onRemoved:snapshot];
    }];
    
    [self.lobby observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        [wself onChanged:snapshot];
    }];
    
    // Monitor Connection so we can disconnect and reconnect
    [RACAble(ConnectionService.shared, isUserActive) subscribeNext:^(id x) {
        [wself onChangedIsUserActive:ConnectionService.shared.isUserActive];
    }];
    
    [RACAble(LocationService.shared, location) subscribeNext:^(id x) {
        [self setLocation:LocationService.shared.location];
    }];
}

// change all users to be offline so we can accurately sync with the server
// ALTERNATIVE: put the field on user itself and have the user change it? naww...
-(void)setAllOffline {
    NSFetchRequest * request = [UserService.shared requestOtherOnline:UserService.shared.currentUser];
    NSArray * users = [ObjectStore.shared requestToArray:request];
    
    [users forEach:^(User * user) {
        [self setUserOffline:user];
    }];
}


// Guaranteed: that we have currentLocation at this point
-(void)onAdded:(FDataSnapshot *)snapshot {
    
    // It doesn't matter if this arrives before the user object
    // it will just add the isOnline, locationLatitude, locationLongitude
    
    User * user = [UserService.shared userWithId:snapshot.name create:YES];
    [user setValuesForKeysWithDictionary:snapshot.value];
    user.isOnline = YES;

    // Come through later and add distance!
    if (self.currentLocation)
        user.distance = [self.currentLocation distanceFromLocation:user.location];
    else
        user.distance = kLocationDistanceInvalid;
    
    NSLog(@"LobbyService: (+) name=%@ distance=%f", user.name, user.distance);
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    User * removed = [UserService.shared userWithId:snapshot.name];
    if (removed) {
        NSLog(@"LobbyService: (-) %@", removed.name);
        [self setUserOffline:removed];
    }
}

-(void)setUserOffline:(User*)user {
    user.isOnline = NO;
    user.locationLatitude = 0;
    user.locationLongitude = 0;
}

-(void)onChanged:(FDataSnapshot*)snapshot {
    [self onAdded:snapshot];
}

-(void)onChangedIsUserActive:(BOOL)active {
    // ignore unless we've already joined once
    if (!self.joinedUser) return;
    
    if (active && !self.joined) {
        [self joinLobby:self.joinedUser];
    } else if (!active && self.joined) {
        [self leaveLobby:self.joinedUser];
    }
}

// Maybe we should have this OBSERVE the location service for the location?
- (void)setLocation:(CLLocation *)location {
    self.currentLocation = location;
    
    if (!self.currentLocation) return;
    
    NSLog(@"LobbyService: Location!");
    
    // Update the location if already joined
    if ((self.joined || self.joining) && self.joinedUser) {
        self.joinedUser.locationLongitude = self.currentLocation.coordinate.longitude;
        self.joinedUser.locationLatitude = self.currentLocation.coordinate.latitude;
        [self saveUserToLobby:self.joinedUser];
    }
    
    // Also update the distance to anyone else already in the system
    NSArray * usersWithLocations = [ObjectStore.shared requestToArray:[self requestUsersWithLocations]];
    [usersWithLocations forEach:^(User*user) {
        user.distance = [self.currentLocation distanceFromLocation:user.location];
    }];
}


// Joins us to the lobby, por favor!
// MAKE SURE that the location is set before doing this!
- (void)joinLobby:(User *)user {
    if (self.joined || self.joining) return;
    NSLog(@"LobbyService: (JOIN)");

    self.joined = NO;
    self.joining = YES;
    self.joinedUser = user;
    
    // If we have a location, save that too
    if (self.currentLocation) {
        user.locationLongitude = self.currentLocation.coordinate.longitude;
        user.locationLatitude = self.currentLocation.coordinate.latitude;
    }
    
    [self saveUserToLobby:user];
}

- (void)saveUserToLobby:(User*)user {
    Firebase * node = [self.lobby childByAppendingPath:user.userId];
    [node onDisconnectRemoveValue];
    [node setValue:user.toLobbyObject withCompletionBlock:^(NSError *error, Firebase *ref) {
        self.joined = YES;
        self.joining = NO;
        NSLog(@"LobbyService: (joined)");
    }];    
}


- (void)leaveLobby:(User*)user {
    if (!self.joined) return;
    NSLog(@"LobbyService: (LEAVE)");
    self.joined = NO;
    Firebase * node = [self.lobby childByAppendingPath:user.userId];
    [node removeValue];
}

- (void)user:(User *)user joinedMatch:(NSString *)matchId {
    user.activeMatchId = matchId;
    [self saveUserToLobby:user];
}

- (void)userLeftMatch:(User*)user {
    user.activeMatchId = nil;
    [self saveUserToLobby:user];
}

-(NSPredicate*)predicateNotFriend:(User*)user {
    return [NSCompoundPredicate notPredicateWithSubpredicate:[UserFriendService.shared predicateIsFBFriendOrFrenemy:user]];
}

#pragma mark - Core Data Requests

- (NSFetchRequest*)requestCloseUsers:(User *)user {
    NSFetchRequest * request = [UserService.shared requestOtherOnline:user];
    NSPredicate * isClose = [NSPredicate predicateWithFormat:@"distance >= 0 AND distance < %f", MAX_SAME_LOCATION_DISTANCE];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[isClose, [self predicateNotFriend:user], request.predicate]];
    return request;
}

// not friends
- (NSFetchRequest*)requestClosestUsers:(User *)user withLimit:(NSInteger)limit {
    NSFetchRequest * request = [UserService.shared requestOtherOnline:user];

    NSPredicate * notFriend = [self predicateNotFriend:user];
    NSPredicate * isFar = [NSPredicate predicateWithFormat:@"distance > %f", MAX_SAME_LOCATION_DISTANCE];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[notFriend, isFar, request.predicate]];
    
    NSSortDescriptor * sortDistance = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
    request.sortDescriptors = @[sortDistance];
    
    request.fetchLimit = limit;
    
    return request;
}

- (NSFetchRequest*)requestUsersWithLocations {
    User * user = UserService.shared.currentUser;
    NSFetchRequest * request = [UserService.shared requestOtherOnline:user];
    NSPredicate * hasLocation = [NSPredicate predicateWithFormat:@"locationLatitude > 0"];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[hasLocation, request.predicate]];
    return request;    
}

@end
