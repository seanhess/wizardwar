//
//  ProfileCell.m
//  WizardWar
//
//  Created by Sean Hess on 7/19/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SettingsProfileCell.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface SettingsProfileCell ()

@end

@implementation SettingsProfileCell

- (id)initWithReuseIdentifier:(NSString*)cellIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    if (self) {
        
        CGSize size = self.contentView.frame.size;
        CGFloat PADDING_LEFT = 100;
        CGFloat PADDING = 4;
        CGRect inputFrame = CGRectMake(PADDING_LEFT, PADDING, size.width - PADDING_LEFT - PADDING, size.height - (2*PADDING+1));

        // Color Display
        UIView * colorView = [[UIView alloc] initWithFrame:inputFrame];
        colorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        colorView.backgroundColor = [UIColor redColor];
        colorView.layer.cornerRadius = 8.0;
        [self.contentView addSubview:colorView];
        self.colorView = colorView;
        
        // Text Input
        UITextField * tf = [[UITextField alloc] initWithFrame:inputFrame];
        tf.textColor = [UIColor darkGrayColor];
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tf.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
        tf.adjustsFontSizeToFitWidth = YES;
        tf.returnKeyType = UIReturnKeyDone;
        [self.contentView addSubview:tf];
        self.inputField = tf;
        
        // Avatar Display
        CGRect avatarFrame = CGRectMake(PADDING_LEFT, PADDING, self.avatarSize.width, self.avatarSize.height);
        UIImageView * avatarImageView = [[UIImageView alloc] initWithFrame:avatarFrame];
        self.avatarImageView = avatarImageView;
        [self.contentView addSubview:self.avatarImageView];        

        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//    }
//    return self;
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(CGSize)avatarSize {
    return CGSizeMake(100, 100);
}

-(void)setLabelText:(NSString*)text {
    self.inputField.placeholder = text;
    self.inputField.text = text;
    self.colorView.hidden = YES;
    self.avatarImageView.hidden = YES;
    self.inputField.hidden = NO;
    self.inputField.enabled = NO;
}

-(void)setFieldText:(NSString*)text {
    self.inputField.placeholder = text;
    self.inputField.text = text;
    self.colorView.hidden = YES;
    self.avatarImageView.hidden = YES;
    self.inputField.hidden = NO;
    self.inputField.enabled = YES;
}

-(void)setColor:(UIColor*)color {
    self.colorView.backgroundColor = color;
    self.colorView.hidden = NO;
    self.inputField.hidden = YES;
    self.avatarImageView.hidden = YES;    
}

-(void)setAvatarURL:(NSURL*)url {
    self.colorView.hidden = YES;
    self.inputField.hidden = YES;
    self.avatarImageView.hidden = NO;
    [self.avatarImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"user.jpg"]];
}


@end
