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
    }
    return self;
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

-(void)authenticateFacebook:(void(^)(BOOL))cb {
    BOOL isOpen = [FBSession.activeSession isOpen];
    NSString *accessToken = [[FBSession.activeSession accessTokenData] accessToken];
    NSLog(@"UMM isOpen=%i accessToken=%@", isOpen, accessToken);
    if (isOpen && accessToken) {
        cb(YES);
        return;
    }
    
    [FBSession openActiveSessionWithReadPermissions:@[] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        BOOL success = (session != nil);
        NSLog(@"AUTHENTICATED %@ %i %@", error, status, session);
        cb(success);
    }];
    
//    [FBSession openActiveSessionWithPublishPermissions:@[] defaultAudience:FBSessionDefaultAudienceOnlyMe allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//        BOOL success = (session != nil);        
//        NSLog(@"WAHOO FATTY %@ %i %@", session, status, error);
//        cb(success);
//    }];
}

-(void)loadFacebookFriends {
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary* result, NSError *error) {
        NSLog(@"BLAH connection=%@ result=%@ error=%@", connection, result, error);
        NSArray* friends = [result objectForKey:@"data"];
        
        NSLog(@"Found: %i friends", friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            int64_t facebookId = friend.id.longLongValue;
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
        
-(NSFetchRequest*)requestFacebookUserWithId:(int64_t)facebookId {
    NSFetchRequest * request = [self requestFacebookFriends];
    request.predicate = [NSPredicate predicateWithFormat:@"facebookId = %lld", facebookId];
    return request;
}

@end
