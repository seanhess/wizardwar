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

@interface PentEmblem ()
@property (nonatomic) CGRect startingFrame;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) PentEmblemHighlight * highlight;
@end

@implementation PentEmblem

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
//        self.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        
        self.backgroundColor = [UIColor clearColor];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.imageView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        [self addSubview:self.imageView];
        
        CGRect frame = self.bounds;
        frame.origin.x = 2;
        frame.origin.y = 2;
        self.highlight = [[PentEmblemHighlight alloc] initWithFrame:frame];
        self.highlight.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.highlight];
        
        NSLog(@"PENTEMBLEM %@", NSStringFromCGSize(self.frame.size));
    }
    return self;
}

-(void)setStatus:(EmblemStatus)status {
    _status = status;

    if (status == EmblemStatusDisabled) {
        self.alpha = 0.3;
    } else {
        self.alpha = 1.0;
    }
    
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
