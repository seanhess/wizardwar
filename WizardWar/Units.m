//
//  Units.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Units.h"

@implementation Units

-(id)initWithZeroY:(CGFloat)zeroY min:(CGFloat)min max:(CGFloat)max {
    if ((self=[super init])) {
        NSLog(@"UNITS %f %f", min, max);
        self.min = min;
        self.max = max;
        self.width = max - min;
        self.zeroY = zeroY;
    }
    return self;
}

-(CGFloat)toX:(CGFloat)units {
    float percent = units / UNITS_MAX;
    return self.min + percent*self.width;
}

@end
