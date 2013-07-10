//
//  ChallengeCell.h
//  WizardWar
//
//  Created by Sean Hess on 7/10/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Challenge.h"

@interface ChallengeCell : UITableViewCell
@property (nonatomic, strong) Challenge * challenge;

-(void)setChallenge:(Challenge *)challenge currentUser:(User*)user;

@end
