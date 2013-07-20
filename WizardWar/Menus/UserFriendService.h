//
//  UserFriendService.h
//  WizardWar
//
//  Created by Sean Hess on 6/24/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Challenge.h"

typedef enum FBStatus {
    FBStatusNotConnected,
    FBStatusConnecting,
    FBStatusConnected
} FBStatus;

@interface UserFriendService : NSObject

@property (nonatomic) FBStatus facebookStatus;

+ (UserFriendService *)shared;

-(void)checkFBStatus:(User*)user;

-(BOOL)hasConnectedFacebook:(User*)user;
-(BOOL)isAuthenticatedFacebook;

-(void)user:(User*)user addFriend:(User*)friend;
-(void)user:(User*)user addChallenge:(Challenge*)challenge;
-(void)user:(User*)user authenticateFacebook:(void(^)(BOOL, User*))cb;
-(void)user:(User*)user disconnectFacebook:(void(^)(void))cb;
-(void)user:(User*)user loadFacebookFriends:(void(^)(void))cb;
-(NSFetchRequest*)requestFacebookFriends;

@end