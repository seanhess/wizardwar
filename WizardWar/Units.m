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
        
        CGSize size = CCDirector.sharedDirector.winSize;
        
        // Make sure it is in landscape
        CGFloat w = size.width;
        CGFloat h = size.height;
        size.width = MAX(w, h);
        size.height = MIN(w, h);
        
        // iPhone 5 aspect ratio
        CGFloat gameWidth, gameHeight;
        if (size.width == 568)
            gameWidth = size.width;
        else gameWidth = 480;
            
        gameHeight = 320;
        
        self.min = 75;
        self.max = gameWidth-75;
        // this should be centered instead!!!
        self.zeroY = gameHeight/2 - 40;
        self.width = self.max - self.min;
        self.maxY = gameHeight;
    }
    return self;
}

-(CGFloat)toX:(CGFloat)units {
    float percent = units / UNITS_MAX;
    return self.min + percent*self.width;
}

@end
