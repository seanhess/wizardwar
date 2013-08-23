//
//  FirebaseConnection.m
//  WizardWar
//
//  Created by Sean Hess on 5/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "ConnectionService.h"
#import <Firebase/Firebase.h>
#import "LobbyService.h"
#import "UserFriendService.h"
#import "UserService.h"
#import "ChallengeService.h"

@interface ConnectionService ()
@property (strong, nonatomic) Firebase * connectionNode;
@property (strong, nonatomic) void(^deepLinkSubscriber)(NSURL*);
@end

// observe whether we disconnect on our own or not
@implementation ConnectionService

+ (ConnectionService *)shared {
    static ConnectionService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ConnectionService alloc] init];
        instance.isUserActive = YES;
        instance.isConnected = NO;
    });
    return instance;
}

-(void)monitorDomain:(Firebase*)domain {
    self.root = domain;
    self.isConnected = NO;
    self.connectionNode = [[domain childByAppendingPath:@".info"] childByAppendingPath:@"connected"];
    
    [self.connectionNode observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        self.isConnected = [snapshot.value boolValue];
        self.isUserActive = self.isConnected;
        NSLog(@"Connection.isConnected: %i", self.isConnected);
    }];
}

-(void)disconnect {    
    // disconnect the other services here?
    [ChallengeService.shared disconnect];
    [LobbyService.shared disconnect];
    [UserService.shared disconnect];
    
    self.isConnected = NO;
    [self.connectionNode removeAllObservers];
    self.connectionNode = nil;
    [self.root removeAllObservers];
    self.root = nil;
}

-(void)setIsUserActive:(BOOL)isUserActive {
    _isUserActive = isUserActive;
    NSLog(@"Connection.isUserActive: %i", self.isUserActive);
}

//-(void)subscribeOnceDeepLinkURL:(void(^)(NSURL*url))cb {
//    self.deepLinkSubscriber = cb;
//}
//
//-(void)unsubscribeDeepLinkURL {
//    self.deepLinkSubscriber = nil;
//}
//
//-(void)setDeepLinkUrl:(NSURL *)deepLinkUrl {
//    _deepLinkUrl = deepLinkUrl;
//    if (self.deepLinkSubscriber) {
//        self.deepLinkSubscriber(deepLinkUrl);
//        self.deepLinkSubscriber = nil;
//    }
//}

@end
