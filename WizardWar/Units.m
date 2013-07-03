//
//  Units.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Units.h"
#import "cocos2d.h"

@implementation Units

// NOOOTEE! size is not correct, because of the content scale!
-(id)init {
    if ((self=[super init])) {
        
        CGFloat w;
        CGSize size = [CCDirector sharedDirector].winSize;
        if (size.height < 700)
            w = size.height;
        else
            w = 480;
        CGFloat h = 320;
        
        self.min = 75;
        self.max = w-75;
        // this should be centered instead!!!
        self.zeroY = h/2 - 40;
        self.width = self.max - self.min;
        self.maxY = 320;
    }
    return self;
}

-(CGFloat)toX:(CGFloat)units {
    float percent = units / UNITS_MAX;
    return self.min + percent*self.width;
}

@end
