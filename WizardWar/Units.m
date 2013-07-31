//
//  Units.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Units.h"
#import "cocos2d.h"
#import "WizardDirector.h"

#define IPAD_SCALE_MODIFIER 1.75

@implementation Units

-(id)initWithRealSize:(CGSize)size {
    if ((self=[super init])) {
        
        self.realSize = size;
        
        if (size.width > 700) // ipad-like
            self.scaleModifier = IPAD_SCALE_MODIFIER;
        else
            self.scaleModifier = 1;
        
        // Make sure it is in landscape
        CGFloat w = size.width;
        CGFloat h = size.height;
        size.width = MAX(w, h);
        size.height = MIN(w, h);
        
        // iPhone 5 aspect ratio
        CGFloat gameWidth, gameHeight;
        if (size.width == 568) // iPhone 5, then use the full width
            gameWidth = size.width;
        else gameWidth = 480;
        
        // with the scale factor, it's wayyyy off the screen otherwise
        gameWidth = size.width / self.scaleModifier;
        
        CGFloat horizontalPadding = 25 + (50 * self.scaleModifier);
        
        // it's too small on the ipad!
        // don't forget! I'm setting a scale factor too!
        // sort of by hand
            
        gameHeight = size.height / self.scaleModifier;
        
        self.min = horizontalPadding;
        self.max = gameWidth-horizontalPadding;
        // this should be centered instead!!!
        self.zeroY = gameHeight/2 - (40 * self.scaleModifier);
        self.width = self.max - self.min;
        self.maxY = gameHeight;
    }
    return self;
}

-(CGFloat)toX:(CGFloat)units {
    return self.min + [self toWidth:units];
}

-(CGFloat)toWidth:(CGFloat)units {
    float percent = units / UNITS_MAX;
    return percent*self.width;
}

- (CGFloat)altitudeY:(NSInteger)altitude {
    if (altitude == 2) {
        return (self.zeroY + (self.maxY - self.zeroY)/2) + 100;
    } else if (altitude == 1) {
        return (self.zeroY + (self.maxY - self.zeroY)/2);
    }
    return self.zeroY;
}

@end
