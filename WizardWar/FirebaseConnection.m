//
//  FirebaseConnection.m
//  WizardWar
//
//  Created by Sean Hess on 5/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "FirebaseConnection.h"
#import <Firebase/Firebase.h>

@interface FirebaseConnection ()
@property (strong, nonatomic) Firebase * connectionNode;
@end


@implementation FirebaseConnection

-(id)initWithFirebaseName:(NSString *)name onConnect:(void (^)(void))onConnect onDisconnect:(void (^)(void))onDisconnect {
    self = [super init];
    if (self) {
        self.connected = NO;
        self.connectionNode = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://%@.firebaseio.com/.info/connected", name]];
        
        [self.connectionNode observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            BOOL wasConnected = self.connected;
            self.connected = [snapshot.value boolValue];
            
            if (wasConnected && !self.connected) {
                if (onDisconnect) onDisconnect();
            }
            
            else if (!wasConnected && self.connected) {
                if (onConnect) onConnect();
            }
        }];
    }
    return self;
}

@end
