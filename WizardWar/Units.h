//
//  Units.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UNITS_MIN 0.0
#define UNITS_MAX 100.0
#define UNITS_DISTANCE (UNITS_MAX-UNITS_MIN)
#define UNITS_MID (UNITS_DISTANCE/2.0)

@interface Units : NSObject
@property (nonatomic) CGFloat min;
@property (nonatomic) CGFloat max;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat zeroY;
@property (nonatomic) CGFloat maxY;
-(CGFloat)toX:(CGFloat)units;
@end
