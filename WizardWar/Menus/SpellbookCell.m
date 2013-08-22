//
//  SpellbookCell.m
//  WizardWar
//
//  Created by Sean Hess on 8/19/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellbookCell.h"
#import "SpellbookService.h"
#import "UIImage+MonoImage.h"
#import "SpellbookProgressView.h"
#import "AppStyle.h"
#import "UIColor+Hex.h"

@interface SpellbookCell ()
@property (weak, nonatomic) IBOutlet SpellbookProgressView *progressView;
@end

@implementation SpellbookCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setSpellRecord:(SpellRecord*)record {
    UIImage * image = [UIImage imageNamed:[SpellbookService.shared spellIconName:record]];
    if (!record.isUnlocked)
        image = [UIImage generateMonoImage:image withColor:[UIColor grayColor]];
    self.icon.image = [SpellbookService.shared spellbookIcon:record];
    
    self.nameLabel.text = [SpellbookService.shared spellTitle:record];
    self.nameLabel.enabled = record.isUnlocked;
    
    [self.progressView setRecord:record];
    
}



// CIEdgeWork

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    self.imageView.frame = CGRectMake(0,0,32,32);
//}

@end
