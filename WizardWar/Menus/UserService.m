//
//  UserFriendService.m
//  WizardWar
//
//  Created by Sean Hess on 6/21/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "UserService.h"
#import <Firebase/Firebase.h>
#import "IdService.h"

@interface UserService ()
@property (nonatomic, strong) Firebase * node;
@end

@implementation UserService

+ (UserService *)shared {
    static UserService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserService alloc] init];
        instance.updated = [RACSubject subject];        
    });
    return instance;
}

- (void)connect {
    self.currentUser = [self loadCurrentUser];
    self.allUsers = [NSMutableDictionary dictionary];
    self.node = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/users"];
    
    __weak UserService * wself = self;
    
    [self.node observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [wself onAdded:snapshot];
    }];
    
    [self.node observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        [wself onRemoved:snapshot];
    }];

}

-(void)onAdded:(FDataSnapshot *)snapshot {
    User * user = [User new];
    [user setValuesForKeysWithDictionary:snapshot.value];
    self.allUsers[snapshot.name] = user;
    [self.updated sendNext:user];
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    User * removed = self.allUsers[snapshot.name];
    if (removed) {
        [self.allUsers removeObjectForKey:snapshot.name];
        [self.updated sendNext:removed];
    }
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
    if (!wizard.name) wizard.name = [NSString stringWithFormat:@"Guest%@", [IdService randomId:4]];
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
