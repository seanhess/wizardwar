//
//  Invite.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Objectable.h"
#import "User.h"

@interface Challenge : NSObject <Objectable>
@property (nonatomic, strong) User * main;
@property (nonatomic, strong) User * opponent;

@property (nonatomic, strong) NSString * mainId;
@property (nonatomic, strong) NSString * opponentId;

-(NSString*)matchId;
@end
