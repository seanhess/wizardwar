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

//@property (nonatomic, strong) NSMutableDictionary * myChallenges;
//@property (nonatomic, strong) RACSubject * updated;

@property (nonatomic, strong) RACSubject * acceptedSignal;

+ (ChallengeService *)shared;
- (Challenge*)user:(User*)user challengeOpponent:(User*)opponent isRemote:(BOOL)isRemote;
- (void)acceptChallenge:(Challenge*)challenge;
- (void)declineChallenge:(Challenge*)challenge;
- (void)removeChallenge:(Challenge*)challenge;
- (void)setChallenge:(Challenge*)challenge status:(ChallengeStatus)status;

- (void)connectAndReset;

- (NSPredicate*)predicateUserIsMain:(User*)user;
- (NSPredicate*)predicateUserIsTargeted:(User*)user;

- (NSFetchRequest*)requestChallengesForUser:(User*)user;
- (NSFetchRequest*)requestChallengesTargetingUser:(User*)user;

- (Challenge*)user:(User*)user challengedByOpponent:(User*)opponent;
- (BOOL)challenge:(Challenge*)challenge isCreatedByUser:(User*)user;

- (void)declineAllChallenges:(User*)user;
- (void)removeUserChallenge:(User*)user;

@end
