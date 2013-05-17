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
    return self.wizardOffset + units*self.pixelsPerUnit;
}

@end
