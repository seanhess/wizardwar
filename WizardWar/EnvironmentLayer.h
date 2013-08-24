//
//  EnvironmentLayer.h
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "CCLayer.h"

#define ENVIRONMENT_CAVE @"cave"
#define ENVIRONMENT_ICE_CAVE @"icecave"
#define ENVIRONMENT_EVIL_FOREST @"evilforest"
#define ENVIRONMENT_CASTLE @"castle"

@interface EnvironmentLayer : CCLayer

-(void)setEnvironment:(NSString*)environment;

@end
