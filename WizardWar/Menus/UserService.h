//
//  UserFriendService.h
//  WizardWar
//
//  Created by Sean Hess on 6/21/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Wizard.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface UserService : NSObject

// currentUser ALWAYS exists with at least the userId
@property (nonatomic, strong) User * currentUser;
@property (nonatomic, readonly) Wizard * currentWizard;
@property (nonatomic, readonly) NSString * userId;

+ (UserService *)shared;

- (void)saveCurrentUser;
- (void)connect;

- (BOOL)isAuthenticated;

- (User*)userWithId:(NSString*)userId;

- (NSPredicate*)predicateIsUser:(NSString*)userId;
- (NSFetchRequest*)requestAllUsers;
- (NSFetchRequest*)requestAllUsersButMe;
- (NSFetchRequest*)requestFriends;

@end
