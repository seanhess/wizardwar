//
//  Invite.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Invite : NSObject
@property (nonatomic, strong) NSString * invitee;
@property (nonatomic, strong) NSString * inviter;
@property (nonatomic, strong) NSString * matchID;
-(NSString*)inviteId;
-(NSDictionary*)toObject;
@end
