//
//  ProfileCell.m
//  WizardWar
//
//  Created by Sean Hess on 7/19/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "ProfileCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ProfileCell ()

@end

@implementation ProfileCell

- (id)initWithReuseIdentifier:(NSString*)cellIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    if (self) {
        
        CGSize size = self.contentView.frame.size;
        CGFloat PADDING_LEFT = 100;
        CGFloat PADDING = 4;
        CGRect inputFrame = CGRectMake(PADDING_LEFT, PADDING, size.width - PADDING_LEFT - PADDING, size.height - (2*PADDING+1));

        // Initialization code
        UIView * colorView = [[UIView alloc] initWithFrame:inputFrame];
        colorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        colorView.backgroundColor = [UIColor redColor];
        colorView.layer.cornerRadius = 8.0;
        [self.contentView addSubview:colorView];
        self.colorView = colorView;
        
        UITextField * tf = [[UITextField alloc] initWithFrame:inputFrame];
        tf.textColor = [UIColor darkGrayColor];
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tf.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
        tf.adjustsFontSizeToFitWidth = YES;
        tf.returnKeyType = UIReturnKeyNext;
        [self.contentView addSubview:tf];
        self.inputField = tf;

        self.selectionStyle = UITableViewCellSelectionStyleNone;
//        self.accessoryType = UITableViewCellAccessoryNone;

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

-(void)setFieldText:(NSString*)text {
    self.inputField.placeholder = text;
    self.inputField.text = text;
    self.colorView.hidden = YES;
    self.inputField.hidden = NO;
}

-(void)setColor:(UIColor*)color {
    self.colorView.backgroundColor = color;
    self.colorView.hidden = NO;
    self.inputField.hidden = YES;
}


@end
