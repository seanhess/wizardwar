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
#import <Firebase/Firebase.h>

// Maintains the connection to the lobby
// Let's you know whenever users join/quit
// Also lets you know local users

@interface LobbyService : NSObject

@property (nonatomic) BOOL joined;
@property (nonatomic) NSInteger totalInLobby;
@property (nonatomic) NSTimeInterval currentServerTime;
@property (nonatomic, strong) Firebase * root;

+ (LobbyService *)shared;

- (void)connect:(Firebase*)root;

- (void)setLocation:(CLLocation*)location;
- (void)joinLobby:(User*)user;
- (void)leaveLobby:(User*)user;
- (void)user:(User*)user joinedMatch:(NSString*)matchId;
- (void)userLeftMatch:(User*)user;

- (NSFetchRequest*)requestCloseUsers:(User*)user;
- (NSFetchRequest*)requestClosestUsers:(User*)user withLimit:(NSInteger)limit;
- (NSFetchRequest*)requestRecentUsers:(User*)user withLimit:(NSInteger)limit;

//-(BOOL)userIsLocal:(User*)user;

// AppID 3hsi88WR19iXGN11miDSH8B031uqyoBYBXHQe9bo
// ClientKey CjkxlkZw0YOMdzdjJzhHfQm4vkPrA2ZWhY9n2Nfo
// Rest API A9kgNN3UKkYDHyUebFe16StpKWVHQZrjCBJyI5Sk
// Master ruR8hExEHPI3Gk9P8lsgNcbYOOP2j7TbkaCwACt4

@end
