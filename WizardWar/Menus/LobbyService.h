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
#import <CoreLocation/CoreLocation.h>

// Maintains the connection to the lobby
// Let's you know whenever users join/quit
// Also lets you know local users

@interface LobbyService : NSObject

@property (nonatomic, readonly) NSDictionary * localUsers;
@property (nonatomic, strong) RACSubject * updated;
@property (nonatomic) BOOL joined;

+ (LobbyService *)shared;
- (void)connect;

- (void)joinLobby:(User*)user location:(CLLocation*)location;
- (void)leaveLobby:(User*)user;

// any lobby user with the given id
- (User*)userWithId:(NSString*)userId;
- (BOOL)userIsOnline:(User*)user;

@end
