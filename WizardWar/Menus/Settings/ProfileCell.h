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

@property (nonatomic, strong) UIView * colorView;
@property (nonatomic, strong) UITextField * inputField;
@property (nonatomic, strong) UIImageView * avatarImageView;
@property (nonatomic, readonly) CGSize avatarSize;

-(id)initWithReuseIdentifier:(NSString*)cellIdentifier;

-(void)setFieldText:(NSString*)text;
-(void)setColor:(UIColor*)color;
-(void)setAvatarURL:(NSURL*)url;

@end
