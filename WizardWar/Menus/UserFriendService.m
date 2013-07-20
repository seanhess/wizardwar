//
//  UserFriendService.m
//  WizardWar
//
//  Created by Sean Hess on 6/24/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "UserFriendService.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookUser.h"
#import "ObjectStore.h"
#import "ConnectionService.h"
#import <ReactiveCocoa.h>
#import <Parse/Parse.h>

@implementation UserFriendService

+ (UserFriendService *)shared {
    static UserFriendService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UserFriendService alloc] init];
    });
    return instance;
}

-(id)init {
    self = [super init];
    if (self) {
        [PFFacebookUtils initializeFacebook];
    }
    return self;
}

-(void)checkFBStatus:(User *)user {
    if ([self hasConnectedFacebook:user] && [self isAuthenticatedFacebook]) {
        self.facebookStatus = FBStatusConnected;
    } else {
        self.facebookStatus = FBStatusNotConnected;
    }
}

-(void)user:(User *)user addFriend:(User *)friend {
    friend.friendPoints++;
}

-(void)user:(User *)user addChallenge:(Challenge *)challenge {
    // Only one of them is (me)
    if (![challenge.main.userId isEqualToString:user.userId])
        [self user:user addFriend:challenge.main];
    else
        [self user:user addFriend:challenge.opponent];
}

-(BOOL)hasConnectedFacebook:(User*)user {
    return (user.facebookId != nil);
}

-(BOOL)isAuthenticatedFacebook {
    BOOL isOpen = [FBSession.activeSession isOpen];
    NSString *accessToken = [[FBSession.activeSession accessTokenData] accessToken];
    return (isOpen && accessToken);
}

-(void)user:(User*)user authenticateFacebook:(void(^)(BOOL, User*))cb {
    
    // callback not required
    if (!cb) cb = ^(BOOL success, User*updated) {};

    if ([self hasConnectedFacebook:user] && [self isAuthenticatedFacebook]) {
        cb(YES, nil);
        return;
    }
    
    self.facebookStatus = FBStatusConnecting;
    
    NSArray *permissionsArray = @[@"user_relationships"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *parseFacebookUser, NSError *error) {
        NSLog(@"UserFriendService.facebook error=%@ user=%@", error, user);
        
        if (!user) {
            if (!error) {
                // cancelled login
            } else {
                // error
            }
            self.facebookStatus = FBStatusNotConnected;
            cb(NO, nil);
        } else {
            // parseFacebookUser.isNew
            if ([self hasConnectedFacebook:user]) {
                self.facebookStatus = FBStatusConnected;
                cb(YES, nil);
                return;
            }
            
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                NSString * facebookId = [result objectForKey:@"id"];
                user.facebookId = facebookId;
                self.facebookStatus = FBStatusConnected;                
                cb(YES, user);
            }];
        }
    }];
}

-(void)user:(User *)user disconnectFacebook:(void (^)(void))cb {
    [[FBSession activeSession] closeAndClearTokenInformation];
    [PFUser logOut];
    self.facebookStatus = FBStatusNotConnected;
    cb();
    // keep the user facebook id so it doesn't disconnect their friends
}

-(void)user:(User*)user loadFacebookFriends:(void (^)(void))cb {
    if (!cb) cb = ^{};
    
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary* result, NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        
        for (NSDictionary<FBGraphUser>* friend in friends) {
            NSString * facebookId = friend.id;
            FacebookUser * user = [ObjectStore.shared requestLastObject:[self requestFacebookUserWithId:facebookId]];
            if (!user) {
                user = [ObjectStore.shared insertNewObjectForEntityForName:@"FacebookUser"];
            }
            user.facebookId = facebookId;
            user.name = friend.name;
            user.firstName = friend.first_name;
            user.lastName = friend.last_name;
            user.username = friend.username;
        }
        cb();
    }];

    // Don't worry about deleting ones that no longer exist
}

-(NSFetchRequest*)requestFacebookFriends {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"FacebookUser"];
    NSSortDescriptor * firstNameSort = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSSortDescriptor * lastNameSort = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    request.sortDescriptors = @[lastNameSort, firstNameSort];
    return request;
}
        
-(NSFetchRequest*)requestFacebookUserWithId:(NSString*)facebookId {
    NSFetchRequest * request = [self requestFacebookFriends];
    request.predicate = [NSPredicate predicateWithFormat:@"facebookId = %@", facebookId];
    return request;
}

@end
