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
@property (nonatomic, weak) UIView * colorView;
@property (nonatomic, weak) UITextField * inputField;

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
        [self.contentView addSubview:tf];
        self.inputField = tf;

        NSLog(@"inputfield 000 %@", NSStringFromCGRect(self.inputField.frame));
        
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

-(void)setUserName:(User*)user {
    self.inputField.placeholder = user.name;
    self.inputField.text = user.name;
    self.textLabel.text = @"Name";
    self.colorView.hidden = YES;
    self.inputField.hidden = NO;
    NSLog(@"inputfield 111 %@", NSStringFromCGRect(self.inputField.frame));
    
//    self.accessoryView = self.inputField;
//    self.detailTextLabel.text = user.name;
//    self.colorView.hidden = YES;
//    self.inputField.hidden = NO;
}

-(void)setUserColor:(User*)user {
    self.textLabel.text = @"Color";
    self.detailTextLabel.text = @"";
    self.colorView.backgroundColor = user.color;
    self.colorView.hidden = NO;
    self.inputField.hidden = YES;
//    self.accessoryView = self.colorView;
}

@end
