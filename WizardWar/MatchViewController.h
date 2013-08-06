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

@protocol MatchViewControllerDelegate <NSObject>
-(void)didFinishChallenge:(Challenge*)challenge didWin:(BOOL)win;
@end

@interface MatchViewController : UIViewController
@property (nonatomic, weak) id<MatchViewControllerDelegate>delegate;
- (void)startMatchAsWizard:(Wizard*)wizard withAI:(Wizard*)ai;
- (void)startChallenge:(Challenge*)challenge currentWizard:(Wizard*)wizard;
@end
