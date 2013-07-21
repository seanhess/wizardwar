//
//  UserFriendService.m
//  WizardWar
//
//  Created by Sean Hess on 6/24/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

// http://tflig.ht/10YUQCE - recruitment thang

// REQUESTS: they only show up in the APP center. It's a tiny thing two things down. Nobody is every going to check it. 
// https://developers.facebook.com/docs/tutorials/ios-sdk-games/requests/
// http://stackoverflow.com/questions/10493498/inviting-multiple-friends-using-facebook-sdk-in-native-ios-app

/// 

#import "UserFriendService.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookUser.h"
#import "ObjectStore.h"
#import "ConnectionService.h"
#import <ReactiveCocoa.h>
#import <Parse/Parse.h>
#import "UserService.h"

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
        [RACAble(UserService.shared, lastUpdatedUser) subscribeNext:^(User*user) {
            if (user.facebookId) {
                FacebookUser * fbuser = [self facebookUserWithId:user.facebookId];
                user.facebookUser = fbuser;
            }
        }];
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


-(FacebookUser*)facebookUserWithId:(NSString *)facebookId {
    return [ObjectStore.shared requestLastObject:[self requestFacebookUserWithId:facebookId]];
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
        NSLog(@"UserFriendService.facebook error=%@ user=%@", error, parseFacebookUser);
        
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
                NSString * facebookId = result[@"id"];
                user.facebookId = facebookId;
                self.facebookStatus = FBStatusConnected;
                
                if (user.isGuestAccount) {
                    NSString * firstName = result[@"first_name"];
                    NSString * lastName = result[@"last_name"];
                    user.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                }
                
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
            FacebookUser * fbuser = [self facebookUserWithId:facebookId];
            if (!fbuser) {
                fbuser = [ObjectStore.shared insertNewObjectForEntityForName:@"FacebookUser"];
            }
            fbuser.facebookId = facebookId;
            fbuser.name = friend.name;
            fbuser.firstName = friend.first_name;
            fbuser.lastName = friend.last_name;
            fbuser.username = friend.username;
            User * user = [UserService.shared userWithPredicate:[self predicateIsUserFacebookId:facebookId]];
            NSLog(@"FacebookUser name=%@ user=%@", fbuser.name, user.name);
            if (user) {
                user.facebookUser = fbuser;
            }
        }
        cb();
    }];
    // Don't worry about deleting ones that no longer exist
}


-(NSURL*)user:(User*)user facebookAvatarURLWithSize:(CGSize)size {
    if (!user.facebookId) return nil;
    CGFloat scale = [[UIScreen mainScreen] scale];
    NSString * url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%i&height=%i", user.facebookId, (int)(size.width*scale), (int)(size.height*scale)];
    return [NSURL URLWithString:url];
}


-(void)openInviteFriendsDialog {
    // APP REQUEST (only in app center = lame)
//    NSMutableDictionary* params = [NSMutableDictionary dictionary];
//    params[@"title"] = @"Invite Friends";
//    params[@"message"] = @"Download Wizard War (Free) on iPhone and iPad so we can play!";
////    params[@"to"] = @"SOME_FACEBOOK_ID";
//    
//    [FBWebDialogs presentRequestsDialogModallyWithSession:nil message:nil title:nil parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
//        
//    }];
    
    
    // SHARE DIALOGE (requires facebook app, must check first = lame)
//    NSURL* url = [NSURL URLWithString:@"http://orbit.al/"];
//    [FBDialogs presentShareDialogWithLink:url
//                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                                      if(error) {
//                                          NSLog(@"Error: %@", error.description);
//                                      } else {
//                                          NSLog(@"Success!");
//                                      }
//                                  }];

}

-(void)openFeedDialogTo:(NSArray *)facebookIds {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"name"] = @"Download Wizard War";
    params[@"caption"] = @"App Store";
    params[@"description"] = @"Come play Wizard War with me! Download the free app for iPhone or iPad!";
    params[@"link"] = @"http://tflig.ht/10YUQCE";
    params[@"picture"] = @"http://wizardwarapp.com/fblogo.png";
    params[@"to"] = [facebookIds lastObject];
//    params[@"tags"] = [facebookIds componentsJoinedByString:@","];
//    params[@"place"] = @"109530785744253";
    
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or publishing a story.
             NSLog(@"Error publishing story.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled story publishing.");
             } else {
                 // Handle the publish feed callback
             }
         }
     }];
    


}


-(void)inviteFriend:(NSString*)facebookId {
    
    // Super easy options:
    // 1. Just display this but don't specify the to field, so they can choose
    // 2. Present this will them filled out
    
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   @"My Title", @"title",
//                                   @"Come check out my app.",  @"message",
//                                   facebookId, @"to",
//                                   nil];
//    
//    [FBWebDialogs presentRequestsDialogModallyWithSession:nil message:@"Come play Wizard War for iPhone and iPad!" title:@"Invite Friends" parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
//        NSLog(@"BACK");
//    }];
}
//
//
//- (void)openGraphThing {
//    id<FBGraphObject> object =
//    [FBGraphObject openGraphObjectForPostWithType:@"object"
//                                            title:@"Wizard War"
//                                            image:@"http://orbit.al/rocket.png"
//                                              url:@"http://orbit.al/"
//                                      description:@"A Game of magic and wands, oh my!"];
//    
//    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
//    //            [action setTags:@[@"100001102534350", @"100006402125833"]]; // I can specify friends here
//    [action setObject:object forKey:@"app"]; // umm...
//    
//    [FBDialogs presentShareDialogWithOpenGraphAction:action
//                                          actionType:@"og.posts"
//                                 previewPropertyName:@"app"
//                                             handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                                                 if(error) {
//                                                     NSLog(@"Error: %@", error.description);
//                                                 } else {
//                                                     NSLog(@"Success!");
//                                                 }
//                                             }];
//}
//
//- (void)openSimpleLinkShare {
//    NSURL * url = [NSURL URLWithString:@"http://orbit.al"];
//    [FBDialogs presentShareDialogWithLink:url handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//        NSLog(@"SHARE %@", error);
//    }];
//}




#pragma mark - Core Data stuff

-(NSPredicate*)predicateIsFrenemy:(User *)user {
    return [NSPredicate predicateWithFormat:@"friendPoints > 0"];
}

-(NSPredicate*)predicateIsFacebookFriend:(User *)user {
    return [NSPredicate predicateWithFormat:@"facebookUser != nil"];
}

-(NSPredicate*)predicateIsUserFacebookId:(NSString *)facebookId {
    return [NSPredicate predicateWithFormat:@"facebookId = %@", facebookId];
}

-(NSPredicate*)predicateIsFBFriendOrFrenemy:(User*)user {
    return [NSCompoundPredicate orPredicateWithSubpredicates:@[[self predicateIsFacebookFriend:user], [self predicateIsFrenemy:user]]];
}

-(NSFetchRequest*)requestAllFacebookUsers {
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"FacebookUser"];
    NSSortDescriptor * firstNameSort = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    NSSortDescriptor * lastNameSort = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    request.sortDescriptors = @[lastNameSort, firstNameSort];
    return request;
}

-(NSFetchRequest*)requestFacebookUserFriends:(User *)user {
    return  [self requestAllFacebookUsers];
}
        
-(NSFetchRequest*)requestFacebookUserWithId:(NSString*)facebookId {
    NSFetchRequest * request = [self requestAllFacebookUsers];
    request.predicate = [NSPredicate predicateWithFormat:@"facebookId = %@", facebookId];
    return request;
}

// Frenemies, and facebook friends, all in the same list
// online first, then by whether they are a facebook friend or not
// finally, by games played
- (NSFetchRequest*)requestFriends:(User *)user {
    NSFetchRequest * request = [UserService.shared requestAllUsersExcept:user];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[self predicateIsFBFriendOrFrenemy:user], request.predicate]];
    NSSortDescriptor * sortFriendPoints = [NSSortDescriptor sortDescriptorWithKey:@"friendPoints" ascending:NO];
    request.sortDescriptors = @[[UserService.shared sortIsOnline], sortFriendPoints];
    
    return request;
}


- (NSFetchRequest*)requestStrangers:(User*)user withLimit:(NSUInteger)limit {
    NSFetchRequest * request = [UserService.shared requestAllUsersExcept:user];
    NSPredicate * notFriend = [NSCompoundPredicate notPredicateWithSubpredicate:[self predicateIsFBFriendOrFrenemy:user]];
    NSSortDescriptor * sortUpdated = [NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:NO];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[notFriend, request.predicate]];
    request.fetchLimit = limit;
    request.sortDescriptors = @[sortUpdated];
    return request;
}





@end
