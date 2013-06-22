//
//  LocalUserService.h
//  WizardWar
//
//  Created by Sean Hess on 6/21/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
#import "User.h"

// Maintains the connection to the lobby
// Let's you know whenever users join/quit
// Also lets you know local users

@interface LobbyService : NSObject

@property (nonatomic, strong) NSMutableDictionary * localUsers;
@property (nonatomic, strong) RACSubject * updated;
@property (nonatomic) BOOL joined;

+ (LobbyService *)shared;
- (void)connect;

- (void)joinLobby:(User*)user;
- (void)leaveLobby:(User*)user;

// any lobby user with the given id
- (User*)userWithId:(NSString*)userId;

@end
