//
//  WarningCell.m
//  WizardWar
//
//  Created by Sean Hess on 8/16/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "WarningCell.h"
#import "AppStyle.h"

@implementation WarningCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib {
//    [self.button setType:BButtonTypeWarning];
}

-(void)setWarningText:(NSString*)text {
    self.textView.backgroundColor = [AppStyle yellowWarningColor];
    self.textView.text = text;
    self.selectionStyle = UITableViewCellEditingStyleNone;
}

-(void)setUserInfo:(User*)user {
    self.textView.backgroundColor = [AppStyle blueMessageColor];
    self.textView.text = [NSString stringWithFormat:@"%@\nLevel %i", user.name, user.wizardLevel];
    self.textView.textAlignment = NSTextAlignmentCenter;
    self.textView.font = [UIFont systemFontOfSize:16.0];
    self.selectionStyle = UITableViewCellSelectionStyleGray;
}

@end
