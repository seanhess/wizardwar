//
//  Units.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Units.h"

@implementation Units

-(CGFloat)pixelsXForUnitPosition:(CGFloat)units {
    NSLog(@"CHECK %f %f", units, self.wizardOffset+units*self.pixelsPerUnit);
    return self.wizardOffset + units*self.pixelsPerUnit;
//    return units*self.pixelsPerUnit;
}

@end
