//
//  OLUnitsService.h
//  WizardWar
//
//  Created by Sean Hess on 7/31/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Units.h"

@interface OLUnitsService : NSObject
@property (nonatomic, strong) Units * units;

+(OLUnitsService *)shared;

@end
