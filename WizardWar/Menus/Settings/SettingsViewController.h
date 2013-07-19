//
//  SettingsViewController.h
//  WizardWar
//
//  Created by Sean Hess on 7/16/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController
@property (nonatomic) BOOL showBuildInfo;
@property (nonatomic) BOOL showFeedback;
@property (nonatomic, strong) void(^onDone)(void);
@end
