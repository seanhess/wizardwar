//
//  LocalPartyService.m
//  WizardWar
//
//  Created by Sean Hess on 6/1/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "LocalPartyService.h"
#import "User.h"
#import <Firebase/Firebase.h>

// Just implement global people for this yo
@interface LocalPartyService ()
@property (nonatomic, strong) NSMutableDictionary* users;
//@property (nonatomic, strong) FirebaseCollection* usersCollection;
@property (nonatomic, strong) Firebase * lobby;
@end

@implementation LocalPartyService

+ (LocalPartyService *)shared {
    static LocalPartyService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LocalPartyService alloc] init];
    });
    return instance;
}

- (void)connect {
    
    self.users = [NSMutableDictionary dictionary];
    
    self.lobby = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/lobby"];
    
    // LOBBY
//    self.usersCollection = [[FirebaseCollection alloc] initWithNode:self.lobby dictionary:self.users type:[User class]];
//    [self.usersCollection didAddChild:reloadTable];
//    [self.usersCollection didRemoveChild:reloadTable];
//    [self.usersCollection didUpdateChild:reloadTable];

    
}

@end
