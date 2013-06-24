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

// Just implement global people for this yo
@interface LobbyService ()
@property (nonatomic, strong) Firebase * lobby;
@property (nonatomic, strong) User * currentUser;
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
    self.localUsers = [NSMutableDictionary dictionary];
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

-(void)onAdded:(FDataSnapshot *)snapshot {
    User * user = [User new];
    [user setValuesForKeysWithDictionary:snapshot.value];
    if ([user.name isEqualToString:self.currentUser.name]) {
        self.joined = YES;
    }
    // That's ALL of them
    else if ([self isLocal:user]) {
        NSLog(@"NEW USER %@", user);
        self.localUsers[snapshot.name] = user;
        [self.updated sendNext:user];
    }
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    User * removed = self.localUsers[snapshot.name];    
    if (removed) {
        [self.localUsers removeObjectForKey:snapshot.name];
        [self.updated sendNext:removed];
    }
}

-(void)onChanged:(FDataSnapshot*)snapshot {
    if (self.localUsers[snapshot.name]) {
        
    }
}

-(BOOL)isLocal:(User*)user {
    return YES;
}


// Joins us to the lobby, por favor!
// MAKE SURE that the location is set before doing this!
- (void)joinLobby:(User *)user {
    NSLog(@"JOIN LOBBY LocationService %@", user);
    
    self.currentUser = user;
    
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
    
    return [self.localUsers.allValues find:^BOOL(User*user) {
        return [user.userId isEqualToString:userId];
    }];
}

@end
