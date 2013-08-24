//
//  SpellbookProgressView.m
//  WizardWar
//
//  Created by Sean Hess on 8/20/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellbookProgressView.h"
#import "UIColor+Hex.h"
#import "AppStyle.h"
#import "SpellbookService.h"

@interface SpellbookProgressView ()
@property (nonatomic, strong) DDProgressView * progressView;
@property (nonatomic) CGFloat progressPadding;
@end

@implementation SpellbookProgressView

- (void)setRecord:(SpellRecord *)record {
    _record = record;
    
    SpellbookLevel level = record.level;
    self.label.hidden = (level <= SpellbookLevelNone);
    self.label.text = [[SpellbookService.shared levelString:level] uppercaseString];
    
    self.progressView.hidden = (level <= SpellbookLevelNone);
    if (!self.progressView.hidden)
        self.progressView.progress = record.progress;
    
    if (level >= SpellbookLevelMaster) {
        self.progressView.frame = self.centerFrame;
        self.label.frame = self.centerFrame;
    } else {
        self.progressView.frame = self.bottomHalfFrame;
        self.label.frame = self.topHalfFrame;
    }
    
    if (record.level < SpellbookLevelAdept) {
        UIColor * color = [UIColor colorFromRGB:0x8F8F8F];
        self.progressColor = color;
        self.label.textColor = color;
    }
    else if (record.level < SpellbookLevelMaster) {
        self.progressColor = [AppStyle blueNavColor];
        self.label.textColor = [AppStyle blueNavColor];
    }
    else {
        self.progressColor = [AppStyle greenOnlineColor];
        self.label.textColor = [UIColor whiteColor];
    }
}


@end
