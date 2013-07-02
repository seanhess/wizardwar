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

@property (nonatomic, strong) User * currentUser;
@property (nonatomic, readonly) Wizard * currentWizard;
@property (nonatomic, strong) NSMutableDictionary * allUsers;
@property (nonatomic, strong) RACSubject * updated;

+ (UserService *)shared;

- (void)connect;
- (BOOL)isAuthenticated;
- (User*)newUserWithName:(NSString*)name;
- (void)saveCurrentUser:(User*)user;

@end
