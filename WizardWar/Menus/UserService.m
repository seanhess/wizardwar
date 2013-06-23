//
//  UserFriendService.m
//  WizardWar
//
//  Created by Sean Hess on 6/21/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "UserService.h"
#import <Firebase/Firebase.h>

@interface UserService ()
@property (nonatomic, strong) Firebase * node;
@end

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
    self.currentUser = [self loadCurrentUser];
    self.node = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/users"];
}

- (User*)loadCurrentUser {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"currentUser"];
    if (!data) return nil;
    User *user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData: data];
    return user;
}

- (void)saveCurrentUser:(User *)user {
    self.currentUser = user;
    
    // Save locally
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.currentUser];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:@"currentUser"];
    
    // Save to firebase
    Firebase * child = [self.node childByAppendingPath:user.userId];
    [child setValue:user.toObject];
}

- (Wizard*)currentWizard {
    Wizard * wizard = [Wizard new];
    wizard.name = self.currentUser.name;
    wizard.wizardType = WIZARD_TYPE_ONE;
    return wizard;
}

- (BOOL)isAuthenticated {
    return self.currentUser != nil;
}

- (User*)newUserWithName:(NSString*)name {
    User * user = [User new];
    user.name = name;
    user.userId = [UIDevice currentDevice].identifierForVendor.UUIDString;
    return user;
    
}



@end
