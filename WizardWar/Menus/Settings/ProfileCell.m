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

@end

@implementation ProfileCell

- (id)initWithReuseIdentifier:(NSString*)cellIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    if (self) {
        // Initialization code
        CGFloat WIDTH = 100;
        UIView * colorView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - (6 + WIDTH), 2, WIDTH, self.contentView.frame.size.height-4)];
        colorView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        colorView.backgroundColor = [UIColor redColor];
        colorView.layer.cornerRadius = 8.0;
        [self.contentView addSubview:colorView];
        self.colorView = colorView;
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
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.textLabel.text = @"Name";
    self.detailTextLabel.text = user.name;
    self.colorView.hidden = YES;
}

-(void)setUserColor:(User*)user {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.textLabel.text = @"Color";
    self.detailTextLabel.text = @"";
    self.colorView.backgroundColor = user.color;
    self.colorView.hidden = NO;
}

@end
