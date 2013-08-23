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
@property (nonatomic, strong) NSString * inviteSubject;
@property (nonatomic, strong) NSString * inviteCaption;
@property (nonatomic, strong) NSString * inviteBody;
@property (nonatomic, strong) NSString * inviteLink;
@property (nonatomic, strong) NSString * invitePictureURL;

+ (UserFriendService *)shared;

-(void)checkFBStatus:(User*)user;

-(BOOL)hasConnectedFacebook:(User*)user;
-(BOOL)isAuthenticatedFacebook;

-(FacebookUser*)facebookUserWithId:(NSString*)facebookId;

-(void)user:(User*)user removeFrenemy:(User*)frenemy;
-(void)user:(User*)user addChallenge:(Challenge*)challenge didWin:(BOOL)didWin;
-(void)user:(User*)user authenticateFacebook:(void(^)(BOOL, User*))cb;
-(void)user:(User*)user disconnectFacebook:(void(^)(void))cb;
-(void)user:(User*)user loadFacebookFriends:(void(^)(void))cb;

-(NSURL*)user:(User*)user facebookAvatarURLWithSize:(CGSize)size;

-(void)openInviteFriendsDialog;
-(void)openFeedDialogTo:(NSArray*)facebookIds;
-(void)inviteFriend:(NSString*)facebookId;

// CORE DATA
-(NSPredicate*)predicateIsFrenemy:(User*)user; // if you've played games together
-(NSPredicate*)predicateIsFacebookFriend:(User*)user; // if you're facebook friends
-(NSPredicate*)predicateIsFBFriendOrFrenemy:(User*)user;

-(NSFetchRequest*)requestAllFacebookUsers;
-(NSFetchRequest*)requestFacebookUserFriends:(User*)user;

-(NSFetchRequest*)requestFriends:(User *)user;
-(NSFetchRequest*)requestFriends:(User *)user isOnline:(BOOL)isOnline;
-(NSFetchRequest*)requestStrangers:(User*)user withLimit:(NSUInteger)limit;

@end