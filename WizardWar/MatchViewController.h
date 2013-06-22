//
//  MatchViewController.h
//  WizardWar
//
//  Created by Sean Hess on 5/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Wizard.h"
#import "Challenge.h"

@interface MatchViewController : UIViewController
- (void)startMatchAsWizard:(Wizard*)wizard withAI:(Wizard*)ai;
- (void)startChallenge:(Challenge*)challenge currentWizard:(Wizard*)wizard;
@end
