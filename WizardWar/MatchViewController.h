//
//  MatchViewController.h
//  WizardWar
//
//  Created by Sean Hess on 5/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Wizard.h"

@interface MatchViewController : UIViewController
- (void)connectToMatchWithId:(NSString*)matchId currentPlayer:(Wizard*)player withAI:(Wizard*)ai;
@end
