//
//  Invite.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Invite.h"

@implementation Invite

-(NSDictionary*)toObject {
    return [self dictionaryWithValuesForKeys:@[@"inviter", @"invitee", @"matchID"]];
}

-(NSString*)inviteId {
    return [NSString stringWithFormat:@"%@-%@", self.inviter, self.invitee];
}
@end
