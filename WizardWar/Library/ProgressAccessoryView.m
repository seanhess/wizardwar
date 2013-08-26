//
//  QuestLevelProgressView.m
//  WizardWar
//
//  Created by Sean Hess on 8/23/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "ProgressAccessoryView.h"
#import <DDProgressView.h>
#import <BButton.h>
#import "AppStyle.h"

@interface ProgressAccessoryView ()

@end


@implementation ProgressAccessoryView

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
    self.label.font = self.defaultFont;
    
    self.backgroundColor = [UIColor clearColor];    
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

- (void)setProgressColor:(UIColor *)color {
    _progressColor = color;
    self.progressView.innerColor = color;
    self.progressView.outerColor = color;
}

- (void)setAlignCenter:(BOOL)alignCenter {
    if (alignCenter) {
        self.progressView.frame = self.centerFrame;
        self.label.frame = self.centerFrame;
    } else {
        self.progressView.frame = self.bottomHalfFrame;
        self.label.frame = self.topHalfFrame;
    }
}

- (UIFont*)defaultFont {
    return [UIFont boldSystemFontOfSize:12.0];
}

- (void)setShowLock:(BOOL)showLock {
    if (showLock) {
        self.label.font = [UIFont fontWithName:@"FontAwesome" size:26.0];
        self.label.text = [NSString stringFromAwesomeIcon:FAIconLock];
        self.alignCenter = YES;
        self.progressView.hidden = YES;
//        self.progressColor = [AppStyle grayLockedColor];
        self.label.textColor = [AppStyle grayLockedColor];
    } else {
        self.alignCenter = NO;
        self.label.font = self.defaultFont;
        self.progressView.hidden = NO;
    }
}


@end
