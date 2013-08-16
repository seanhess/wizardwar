//
//  WarningCell.m
//  WizardWar
//
//  Created by Sean Hess on 8/16/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "WarningCell.h"

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

@end
