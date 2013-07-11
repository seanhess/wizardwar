//
//  FirebaseConnection.h
//  WizardWar
//
//  Created by Sean Hess on 5/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

// helps you track presence and connection status

#import <Foundation/Foundation.h>

@interface ConnectionService : NSObject
@property (nonatomic) BOOL isConnected;
@property (nonatomic) BOOL isUserActive;

+(ConnectionService *)shared;
-(void)monitorDomain:(NSURL*)domain;

@end
