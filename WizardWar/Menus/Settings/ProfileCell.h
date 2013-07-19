//
//  ProfileCell.h
//  WizardWar
//
//  Created by Sean Hess on 7/19/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileCell : UITableViewCell

@property (nonatomic, weak) UIView * colorView;
@property (nonatomic, weak) UITextField * inputField;

-(id)initWithReuseIdentifier:(NSString*)cellIdentifier;

-(void)setFieldText:(NSString*)text;
-(void)setColor:(UIColor*)color;

@end
