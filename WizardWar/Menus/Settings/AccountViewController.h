//
//  AccountViewController.h
//  WizardWar
//
//  Created by Sean Hess on 6/23/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AccountFormDelegate <NSObject>
-(void)didSubmitAccountForm:(NSString*)name;
@end

@interface AccountViewController : UIViewController
@property (nonatomic, weak) id<AccountFormDelegate> delegate;
@end
