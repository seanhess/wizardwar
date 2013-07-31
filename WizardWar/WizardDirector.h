//
//  WWDirector.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

// Stupid name for class that manages

#import "cocos2d.h"
#import "Units.h"

@interface WizardDirector : CCDirectorIOS;

+(CCDirectorIOS*)initializeWithUnits:(Units*)units;
+(void)runLayer:(CCLayer*)layer;
+(void)stop;
+(void)start;
+(void)unload;

@end
