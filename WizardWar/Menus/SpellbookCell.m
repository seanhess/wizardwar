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
    BOOL enabled = record.isDiscovered;
    UIImage * image = [UIImage imageNamed:[SpellbookService.shared spellIconName:record]];
    if (!enabled) image = [UIImage generateMonoImage:image withColor:[UIColor grayColor]];
    self.icon.image = image;
    
    [self.progressView setRecord:record];
    
    if (record.level < SpellbookLevelAdept) {
        self.progressView.progressColor = [UIColor grayColor];
        self.progressView.label.textColor = [UIColor grayColor];
    }
    else if (record.level < SpellbookLevelMaster) {
        self.progressView.progressColor = [AppStyle blueNavColor];
        self.progressView.label.textColor = [AppStyle blueNavColor];
    }
    else {
        self.progressView.progressColor = [AppStyle greenOnlineColor];
        self.progressView.label.textColor = [UIColor whiteColor];
    }
    
    // COLORS:
    // none = gray
    // novice = gray?
    // adept = yellow?
    // master = green
}

// CIEdgeWork

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    self.imageView.frame = CGRectMake(0,0,32,32);
//}

@end
