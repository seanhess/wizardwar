//
//  PentEmblem.m
//  WizardWar
//
//  Created by ; Skinner on 5/17/13.
//  Copyright (c) 2013 WizardWar. All rights reserved.
//

#import "PentEmblem.h"
#import <QuartzCore/QuartzCore.h>
#import "PentEmblemHighlight.h"
#import <DACircularProgressView.h>

@interface PentEmblem ()
@property (nonatomic) CGRect startingFrame;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) PentEmblemHighlight * highlight;
@property (nonatomic, strong) DACircularProgressView * timerView;
@property (nonatomic) BOOL configuredTimerView;
@end

@implementation PentEmblem

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // I had changed the anchor point for transforms to the view
//        self.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        
        CGFloat innerSizeWidth = 60;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            innerSizeWidth = 80;
        }
        
        CGSize outerSize = self.frame.size;
        CGSize innerSize = CGSizeMake(innerSizeWidth, innerSizeWidth);
        CGRect innerFrame = CGRectMake((outerSize.width-innerSize.width)/2, (outerSize.height-innerSize.height)/2, innerSize.width, innerSize.height);
        
//        self.backgroundColor = [UIColor redColor];
        self.imageView = [[UIImageView alloc] initWithFrame:innerFrame];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.imageView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        [self addSubview:self.imageView];
        
        CGRect frame = innerFrame;
        frame.origin.x += 2;
        frame.origin.y += 2;
        self.highlight = [[PentEmblemHighlight alloc] initWithFrame:frame];
        self.highlight.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.highlight];
        
        self.configuredTimerView = NO;
        self.timerView = [[DACircularProgressView alloc] initWithFrame:innerFrame];
        self.timerView.hidden = YES;
        [self addSubview:self.timerView];
    }
    return self;
}

-(void)setStatus:(EmblemStatus)status {
    _status = status;

    self.alpha = 1.0;
//    if (status == EmblemStatusDisabled) {
//        self.alpha = 0.3;
//    } else {
//        self.alpha = 1.0;
//    }
    
    if (status == EmblemStatusSelected) {
        self.highlight.borderColor = [UIColor whiteColor];
    } else {
        self.highlight.borderColor = [UIColor blackColor];
    }

//    [UIView animateWithDuration:0.3 animations:^{
//        if (status == EmblemStatusSelected)
//            self.alpha = 1.0;
//        else
//            self.alpha = 0.8;
//        
////        if (status == EmblemStatusDisabled)
////            self.transform = CGAffineTransformMakeScale(0.1, 0.1);
////        else
////            self.transform = CGAffineTransformIdentity;    
//    }];
}

-(void)setEnabledProgress:(CGFloat)enabledProgress {
    _enabledProgress = enabledProgress;
    
    if (!self.configuredTimerView) {
        self.configuredTimerView = YES;
        self.timerView.progressTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.timerView.trackTintColor = [UIColor clearColor];
        self.timerView.thicknessRatio = 1.0;
        self.timerView.roundedCorners = NO;
    }
    
    self.timerView.hidden = NO;
    self.timerView.progress = 1-enabledProgress;
}

-(void)setSize:(CGSize)size {
    _size = size;
    
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
    
//    CGRect imageFrame = self.imageView.frame;
//    imageFrame.size = size;
//    self.imageView.frame = imageFrame;
//    
//    CGRect highlightFrame = self.highlight.frame;
//    highlightFrame.size = size;
//    self.highlight.frame = highlightFrame;
}

-(void)flashHighlight {
    self.highlight.borderColor = [UIColor whiteColor];
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.highlight.borderColor = [UIColor blackColor];
        dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
            self.highlight.borderColor = [UIColor whiteColor];
            dispatch_time_t popTime3 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime3, dispatch_get_main_queue(), ^(void){
                self.status = self.status;
            });
        });
    });
}

-(void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
}

-(void)setMana:(NSInteger)mana {
    if (mana > MAX_MANA) mana = MAX_MANA;
    else if (mana < 0) mana = 0;
    _mana = mana;
    
    // if they have 0 mana, it should be gone
    // 1-3 should be 50% + 1-3
    [UIView animateWithDuration:0.3 animations:^{
        float scale = 0.5 + ((float)mana / (MAX_MANA*2));
        if (mana == 0) scale = 0;
        self.transform = CGAffineTransformMakeScale(scale, scale);
    }];
}

@end
