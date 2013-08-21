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
    self.icon.image = image;
    
    self.nameLabel.text = [SpellbookCell spellTitle:record];
    self.nameLabel.enabled = record.isUnlocked;
    
    [self.progressView setRecord:record];
    
    if (record.level < SpellbookLevelAdept) {
        UIColor * color = [UIColor colorFromRGB:0x8F8F8F];
        self.progressView.progressColor = color;
        self.progressView.label.textColor = color;
    }
    else if (record.level < SpellbookLevelMaster) {
        self.progressView.progressColor = [AppStyle blueNavColor];
        self.progressView.label.textColor = [AppStyle blueNavColor];
    }
    else {
        self.progressView.progressColor = [AppStyle greenOnlineColor];
        self.progressView.label.textColor = [UIColor whiteColor];
    }
}

+ (NSString*)spellTitle:(SpellRecord*)record {
    if (record.isDiscovered) {
        return record.name;
    } else {
        return @"?";
    }
}



// CIEdgeWork

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    self.imageView.frame = CGRectMake(0,0,32,32);
//}

@end
