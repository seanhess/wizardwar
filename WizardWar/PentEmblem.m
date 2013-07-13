//
//  PentEmblem.m
//  WizardWar
//
//  Created by Dallin Skinner on 5/17/13.
//  Copyright (c) 2013 WizardWar. All rights reserved.
//

#import "PentEmblem.h"
#import <QuartzCore/QuartzCore.h>

@interface PentEmblem ()
@property (nonatomic) CGRect startingFrame;
@end

@implementation PentEmblem

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
    }
    return self;
}

-(void)setStatus:(EmblemStatus)status {
    _status = status;
    
    
    [UIView animateWithDuration:0.3 animations:^{
        if (status == EmblemStatusSelected)
            self.alpha = 1.0;
        else
            self.alpha = 0.5;
        
//        if (status == EmblemStatusDisabled)
//            self.transform = CGAffineTransformMakeScale(0.1, 0.1);
//        else
//            self.transform = CGAffineTransformIdentity;    
    }];
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
