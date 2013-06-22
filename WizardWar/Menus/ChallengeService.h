//
//  ChallengeService.h
//  WizardWar
//
//  Created by Sean Hess on 6/21/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
#import "User.h"
#import "Challenge.h"

@interface ChallengeService : NSObject

@property (nonatomic, strong) NSMutableDictionary * myChallenges;
@property (nonatomic, strong) RACSubject * updated;

+ (ChallengeService *)shared;
- (void)connect;
- (Challenge*)user:(User*)user challengeOpponent:(User*)opponent;

@end
