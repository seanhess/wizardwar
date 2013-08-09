//
//  Challenge.h
//  WizardWar
//
//  Created by Sean Hess on 7/10/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Objectable.h"
#import "User.h"

typedef enum ChallengeStatus {
    ChallengeStatusPending,
    ChallengeStatusAccepted,
    ChallengeStatusDeclined,
} ChallengeStatus;


@interface Challenge : NSManagedObject <Objectable>

@property (nonatomic) int16_t status;
@property (nonatomic, retain) NSString * matchId;

@property (nonatomic, retain) User *main;
@property (nonatomic, retain) User *opponent;

@property (nonatomic, strong) NSString * mainId;
@property (nonatomic, strong) NSString * opponentId;
@property (nonatomic) BOOL isDeletedRemotely;

-(User*)findOpponent:(User*)user;

@end
