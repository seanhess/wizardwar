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

@implementation LobbyService

+ (LobbyService *)shared {
    static LobbyService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LobbyService alloc] init];
    });
    return instance;
}

- (void)connect {
    
    // The LOBBY contains a list of users currently active in the game
    self.updated = [RACSubject subject];
    self.localUsers = [NSMutableDictionary dictionary];
    self.lobby = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/lobby"];
    self.joined = NO;
    
    __weak LobbyService * wself = self;

    [self.lobby observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [wself onAdded:snapshot];
    }];
    
    [self.lobby observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        [wself onRemoved:snapshot];
    }];
}

-(void)onAdded:(FDataSnapshot *)snapshot {
    User * user = [User new];
    [user setValuesForKeysWithDictionary:snapshot.value];
    if ([user.name isEqualToString:self.currentUser.name]) {
        self.joined = YES;
    }
    else if ([self isLocal:user]) {
        self.localUsers[snapshot.name] = user;
        [self.updated sendNext:self.localUsers];
    }
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    if (self.localUsers[snapshot.name]) {
        [self.localUsers removeObjectForKey:snapshot.name];
        [self.updated sendNext:self.localUsers];
    }
}

-(BOOL)isLocal:(User*)user {
    return YES;
}


// Joins us to the lobby, por favor!
- (void)joinLobby:(User *)user {
    self.currentUser = user;
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
