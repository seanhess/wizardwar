//
//  UserFriendService.m
//  WizardWar
//
//  Created by Sean Hess on 6/21/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "UserService.h"
#import "IdService.h"

@implementation UserService

+ (UserService *)shared {
    static UserService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserService alloc] init];
    });
    return instance;
}

- (void)connect {
    // load user?
    self.currentUser = [self loadCurrentUser];
    if (!self.currentUser) {
        self.currentUser = [self guestUser];
        [self saveCurrentUser];
    }
}

- (User*)loadCurrentUser {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"currentUser"];
    if (!data) return nil;
    User *user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData: data];
    return user;
}

- (void)saveCurrentUser {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.currentUser];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:@"currentUser"];
}

- (User*)guestUser {
    User * user = [User new];
    NSString * name = [NSString stringWithFormat:@"Guest%@", [IdService randomId:4]];
    user.userId = name;
    user.name = name;
    return user;
}

- (Wizard*)currentWizard {
    Wizard * wizard = [Wizard new];
    wizard.name = self.currentUser.name;
    wizard.wizardType = WIZARD_TYPE_ONE;
    return wizard;
}



@end
