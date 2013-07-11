//
//  FirebaseConnection.m
//  WizardWar
//
//  Created by Sean Hess on 5/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "ConnectionService.h"
#import <Firebase/Firebase.h>

@interface ConnectionService ()
@property (strong, nonatomic) Firebase * connectionNode;
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

-(void)monitorDomain:(NSURL*)domain {
    self.isConnected = NO;
    NSString * url = [[[domain URLByAppendingPathComponent:@".info"] URLByAppendingPathComponent:@"connected"] description];
    self.connectionNode = [[Firebase alloc] initWithUrl:url];
    
    [self.connectionNode observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        self.isConnected = [snapshot.value boolValue];
        NSLog(@"Connection.isConnected: %i", self.isConnected);
    }];
}

-(void)setIsUserActive:(BOOL)isUserActive {
    _isUserActive = isUserActive;
    NSLog(@"Connection.isUserActive: %i", self.isUserActive);
}

@end
