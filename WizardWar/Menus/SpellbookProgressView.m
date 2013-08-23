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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.progressPadding = 4;
    
    self.progressView = [[DDProgressView alloc] initWithFrame:self.bottomHalfFrame];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.progressView];
    
    self.label = [[UILabel alloc] initWithFrame:self.topHalfFrame];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.label];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.font = [UIFont boldSystemFontOfSize:12.0];
}

- (CGRect)topHalfFrame {
    return CGRectMake(0, 0, self.frame.size.width-self.progressPadding, self.frame.size.height/2-self.progressPadding);
}

- (CGRect)bottomHalfFrame {
    return CGRectMake(0, self.frame.size.height/2-self.progressPadding, self.frame.size.width-self.progressPadding, self.frame.size.height/2);
}


- (CGRect)centerFrame {
    CGFloat height = 22;
    return CGRectMake(0, (self.frame.size.height-height)/2, self.frame.size.width-self.progressPadding, 22);
}


- (void)setRecord:(SpellRecord *)record {
    _record = record;
    
    SpellbookLevel level = record.level;
    self.label.hidden = (level <= SpellbookLevelNone);
    self.label.text = [self levelString:level];
    
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

- (void)setProgressColor:(UIColor *)color {
    self.progressView.innerColor = color;
    self.progressView.outerColor = color;
}

-(NSString*)levelString:(SpellbookLevel)level {
    return [[SpellbookService.shared levelString:level] uppercaseString];
}



- (void)setProgress:(CGFloat)progress {
    self.progressView.progress = progress;
}

@end
