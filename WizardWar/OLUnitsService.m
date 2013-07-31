//
//  OLUnitsService.m
//  WizardWar
//
//  Created by Sean Hess on 7/31/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "OLUnitsService.h"

@implementation OLUnitsService

+ (OLUnitsService *)shared {
    static OLUnitsService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OLUnitsService alloc] init];
    });
    return instance;
}

@end
