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
@property (nonatomic) CGFloat groundY;
@property (nonatomic) CGFloat pixelsPerUnit;
@property (nonatomic) CGFloat wizardOffset;
-(CGFloat)pixelsXForUnitPosition:(CGFloat)units;
@end
