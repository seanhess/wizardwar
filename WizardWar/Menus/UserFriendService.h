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

@interface UserFriendService : NSObject

+ (UserFriendService *)shared;

-(BOOL)hasConnectedFacebook:(User*)user;

-(void)user:(User*)user addFriend:(User*)friend;
-(void)user:(User*)user addChallenge:(Challenge*)challenge;
-(void)authenticateFacebook:(void(^)(BOOL))cb;
-(void)loadFacebookFriends;
-(NSFetchRequest*)requestFacebookFriends;

@end