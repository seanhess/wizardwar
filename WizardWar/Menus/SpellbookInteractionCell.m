//
//  SpellbookInteractionCell.m
//  WizardWar
//
//  Created by Sean Hess on 8/22/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellbookInteractionCell.h"

@implementation SpellbookInteractionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
//        self.imageView.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat padding = 4;
    CGFloat height = self.frame.size.height-2*padding;
    self.imageView.frame = CGRectMake(padding, padding, height, height);
}

@end
