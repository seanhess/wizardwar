//
//  UserFriendService.m
//  WizardWar
//
//  Created by Sean Hess on 6/24/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "UserFriendService.h"

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
        self.friends = [self loadFriends];
    }
    return self;
}

-(void)user:(User *)user addFriend:(User *)friend {
    friend.friendPoints++;
    NSLog(@"Add Friend: %@", friend);
    [self.friends setObject:friend forKey:user.userId];
    [self saveFriends:self.friends];
    
    // TESTING
    NSMutableDictionary * friends = [self loadFriends];
    NSLog(@"FRIENDS! %@", friends);
}

-(void)user:(User *)user addChallenge:(Challenge *)challenge {
    // Only one of them is (me)
    if (![challenge.main.userId isEqualToString:user.userId])
        [self user:user addFriend:challenge.main];
    else
        [self user:user addFriend:challenge.opponent];
}

-(NSString*)friendsFilePath {
    NSString * directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [directory stringByAppendingPathComponent:@"friends.plist"];
}

-(void)saveFriends:(NSDictionary*)friends {
    NSLog(@"SAVE FRIENDS");
    BOOL success = [NSKeyedArchiver archiveRootObject:friends toFile:self.friendsFilePath];
    if (!success) NSLog(@"ERROR! UserFriendService.saveFriends - did not save");
}

-(NSMutableDictionary*)loadFriends {
    NSMutableDictionary * friends = [NSKeyedUnarchiver unarchiveObjectWithFile:self.friendsFilePath];
    if (!friends) friends = [NSMutableDictionary dictionary];
    return friends;
}

-(void)clearFriends {
    self.friends = [NSMutableDictionary dictionary];
    [self saveFriends:self.friends];
}


@end
