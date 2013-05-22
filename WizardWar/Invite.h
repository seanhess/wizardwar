//
//  Invite.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Objectable.h"

@interface Invite : NSObject <Objectable>
@property (nonatomic, strong) NSString * invitee;
@property (nonatomic, strong) NSString * inviter;
@property (nonatomic, strong) NSString * matchID;
-(NSString*)inviteId;
@end
