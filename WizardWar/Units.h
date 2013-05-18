//
//  Units.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UNITS_MIN 0
#define UNITS_MAX 100

@interface Units : NSObject
-(id)initWithZeroY:(CGFloat)zeroY min:(CGFloat)min max:(CGFloat)max;
@property (nonatomic) CGFloat min;
@property (nonatomic) CGFloat max;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat zeroY;
-(CGFloat)toX:(CGFloat)units;
@end
