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
@property (nonatomic) NSTimeInterval lastFirebaseConnect;
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
    
    self.lastFirebaseConnect = [self loadLastFirebaseConnect];
    NSLog(@"UserService: lastFirebaseConnect:%f", self.lastFirebaseConnect);
    
    FQuery * query = [self.node queryStartingAtPriority:@(self.lastFirebaseConnect)];
    
//    NSLog(@"UserService lastFirebaseConnect=%f", self.lastFirebaseConnect);
    
    __weak UserService * wself = self;

    [query observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [wself onAdded:snapshot];
    }];
    
    [query observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        [wself onRemoved:snapshot];
    }];
    
    [query observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        [wself onChanged:snapshot];
    }];
}

- (void)saveCurrentUser {
    // Save to firebase
    User * user = self.currentUser;
    if (!user) return;
    Firebase * child = [self.node childByAppendingPath:user.userId];
    [child setValue:user.toObject andPriority:kFirebaseServerValueTimestamp];
}

-(void)onAdded:(FDataSnapshot *)snapshot {
    NSString * userId = snapshot.name;
    User * user = [self userWithId:userId create:YES];
    [user setValuesForKeysWithDictionary:snapshot.value];
    user.updated = ([snapshot.priority doubleValue] / 1000.0); // comes down in milliseconds
    NSLog(@"UserService: (+) %f %@ ", user.updated, user.name);
}

-(void)onRemoved:(FDataSnapshot*)snapshot {
    NSString * userId = snapshot.name;
    User * user = [self userWithId:userId];
    if (user) {
        NSLog(@"UserService: (-) %@", user.name);            
        [ObjectStore.shared.context deleteObject:user];
    }
}

-(void)onChanged:(FDataSnapshot*)snapshot {
    [self onAdded:snapshot];
}

-(NSTimeInterval)loadLastFirebaseConnect {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    NSSortDescriptor * sortByLastUpdated = [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:NO];
    request.sortDescriptors = @[sortByLastUpdated];
    User * user = [ObjectStore.shared requestLastObject:request];
    return user.updated;
}

- (User*)currentUser {
    if (!_currentUser) {
        User * user = [self userWithId:self.userId create:YES];
        self.currentUser = user;
    }
        
    return _currentUser;
}

- (Wizard*)currentWizard {
    // TODO, actually save this information, yo?
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



# pragma mark - Users

- (User*)userWithId:(NSString*)userId {
    return [self userWithId:userId create:NO];
}

- (User*)userWithId:(NSString*)userId create:(BOOL)create {
    NSFetchRequest * request = [self requestAllUsers];
    request.predicate = [self predicateIsUser:userId];
    User * user = [ObjectStore.shared requestLastObject:request];
    if (!user && create) {
        user = [ObjectStore.shared insertNewObjectForEntityForName:self.entityName];
        user.userId = userId;
    }
    return user;
}

# pragma mark - Core Data

- (NSPredicate*)predicateIsUser:(NSString*)userId {
    return [NSPredicate predicateWithFormat:@"userId = %@", userId];
}

-(NSPredicate*)predicateIsFriend {
    return [NSPredicate predicateWithFormat:@"friendPoints > 0"];
}

- (NSFetchRequest*)requestAllUsers {
    // valid users include:
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"name != nil"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
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
//    NSPredicate * hasDeviceToken = [NSPredicate predicateWithFormat:@"deviceToken != nil"];    
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[self predicateIsFriend], request.predicate]];
    
    NSSortDescriptor * sortFriendPoints = [NSSortDescriptor sortDescriptorWithKey:@"friendPoints" ascending:NO];
    NSSortDescriptor * sortIsOnline = [NSSortDescriptor sortDescriptorWithKey:@"isOnline" ascending:NO];
    request.sortDescriptors = @[sortIsOnline, sortFriendPoints];
    
    return request;
}

- (NSFetchRequest*)requestOtherOnline {
    NSFetchRequest * request = [self requestAllUsersButMe];
    NSPredicate * isOnline = [NSPredicate predicateWithFormat:@"isOnline = YES"];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[isOnline, request.predicate]];
    return request;
}




@end
