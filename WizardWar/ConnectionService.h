//
//  FirebaseConnection.h
//  WizardWar
//
//  Created by Sean Hess on 5/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

// helps you track presence and connection status

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>

@interface ConnectionService : NSObject
@property (nonatomic) BOOL isConnected;
@property (nonatomic) BOOL isUserActive;
@property (nonatomic, strong) NSURL * deepLinkUrl;
@property (nonatomic, strong) Firebase * root;

+(ConnectionService *)shared;
-(void)monitorDomain:(Firebase*)domain;
-(void)disconnect;
//-(void)subscribeOnceDeepLinkURL:(void(^)(NSURL*url))cb;
//-(void)unsubscribeDeepLinkURL;

@end
