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
#import <CoreData/CoreData.h>
#import "ObjectStore.h"

@interface UserService ()
@property (nonatomic, strong) Firebase * node;
@property (nonatomic, strong) NSString * deviceToken;
@property (nonatomic, strong) NSString * entityName;
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
    self.node = [[Firebase alloc] initWithUrl:@"https://wizardwar.firebaseIO.com/users"];
    self.entityName = @"User";
    
    __weak UserService * wself = self;

    [self.node observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [wself onAdded:snapshot];
    }];
    
    [self.node observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        [wself onRemoved:snapshot];
    }];
}

- (void)saveCurrentUser {
    // Save to firebase
    User * user = self.currentUser;
    if (!user) return;
    Firebase * child = [self.node childByAppendingPath:user.userId];
    [child setValue:user.toObject];
}

-(void)onAdded:(FDataSnapshot *)snapshot {
    NSString * userId = snapshot.name;
    User * user = [self userWithId:userId];
    if (!user) user = [ObjectStore.shared insertNewObjectForEntityForName:self.entityName];
    [user setValuesForKeysWithDictionary:snapshot.value];
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    NSString * userId = snapshot.name;
    User * user = [self userWithId:userId];
    if (user)
        [ObjectStore.shared.context deleteObject:user];
}

- (User*)currentUser {
    if (!_currentUser) {
        User * user = [self userWithId:self.userId];
        if (!user) {
            // no user information has been set. To make things easy, return an empty user object
            // but with only the userId field set
            // NOT synced
            
            // aww, crap, this is no good!
            // you could end up with 2 of them
            
            // because I haven't synced yet, right?
            // wait, no, that doesn't matter. There's no way it doesn't exist locally
            user = [ObjectStore.shared insertNewObjectForEntityForName:self.entityName];
            user.userId = self.userId;
        }
        
        self.currentUser = user;
    }
        
    return _currentUser;
}

- (Wizard*)currentWizard {
    // TODO, actually save this information, yo?
    // NSUserDefaults ftw
    Wizard * wizard = [Wizard new];
    wizard.name = self.currentUser.name;
    if (!wizard.name) wizard.name = [NSString stringWithFormat:@"Guest%@", [IdService randomId:4]];
    wizard.wizardType = WIZARD_TYPE_ONE;
    return wizard;
}

- (BOOL)isAuthenticated {
    return self.currentUser.name != nil;
}

- (NSString*)userId {
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}



# pragma mark - Core Data

- (NSPredicate*)predicateIsUser:(NSString*)userId {
    return [NSPredicate predicateWithFormat:@"userId = %@", userId];
}

- (NSFetchRequest*)requestAllUsers {
    // valid users include:
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"name != nil"]; // AND deviceToken != nil"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
    return request;
}

- (NSFetchRequest*)requestAllUsersButMe {
    NSFetchRequest * request = [self requestAllUsers];
    NSPredicate * notMe = [NSCompoundPredicate notPredicateWithSubpredicate:[self predicateIsUser:self.currentUser.userId]];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[notMe, request.predicate]];
    return request;
}

- (NSFetchRequest*)requestFriends {
    NSFetchRequest * request = [self requestAllUsersButMe];
    NSPredicate * isFriend = [NSPredicate predicateWithFormat:@"friendPoints > 0"];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[isFriend, request.predicate]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"friendPoints" ascending:NO]];
    return request;
}

- (User*)userWithId:(NSString*)userId {
    NSFetchRequest * request = [self requestAllUsers];
    request.predicate = [self predicateIsUser:userId];
    return [ObjectStore.shared requestLastObject:request];
}


@end
