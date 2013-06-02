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
        if (status == EmblemStatusHighlight)
            self.alpha = 1.0;
        else
            self.alpha = 0.5;
        
        if (status == EmblemStatusDisabled)
            self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        else
            self.transform = CGAffineTransformIdentity;    
    }];
    
}
@end
