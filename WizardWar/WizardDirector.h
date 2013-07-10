//
//  WWDirector.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

// Stupid name for class that manages

#import "cocos2d.h"

@interface WizardDirector : CCDirectorIOS;

+(CCDirectorIOS*)initializeWithBounds:(CGRect)bounds;
+(void)runLayer:(CCLayer*)layer;
+(void)stop;
+(void)start;
+(void)unload;

@end
