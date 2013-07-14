//
//  AccountColorViewController.h
//  WizardWar
//
//  Created by Sean Hess on 7/14/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AccountColorDelegate <NSObject>
-(void)didSelectColor:(UIColor*)color;
@end

@interface AccountColorViewController : UIViewController
@property (weak, nonatomic) id<AccountColorDelegate> delegate;
@end
