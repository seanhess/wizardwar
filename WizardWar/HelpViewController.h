//
//  HelpViewController.h
//  WizardWar
//
//  Created by Sean Hess on 8/7/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HelpDelegate <NSObject>

-(void)didTapHelpClose;

@end

@interface HelpViewController : UIViewController
@property (nonatomic, weak) id<HelpDelegate>delegate;
@end
