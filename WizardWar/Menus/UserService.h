//
//  UserFriendService.h
//  WizardWar
//
//  Created by Sean Hess on 6/21/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserService : NSObject

@property (nonatomic, strong) User * currentUser;

+ (UserService *)shared;
- (void)connect;

@end
