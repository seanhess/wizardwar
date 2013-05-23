//
//  FirebaseConnection.h
//  WizardWar
//
//  Created by Sean Hess on 5/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

// helps you track presence and connection status

#import <Foundation/Foundation.h>

@interface FirebaseConnection : NSObject
@property (nonatomic) BOOL connected;
-(id)initWithFirebaseName:(NSString*)name onConnect:(void(^)(void))onConnect onDisconnect:(void(^)(void))onDisconnect;
@end
