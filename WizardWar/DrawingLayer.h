//
//  DrawingLayer.h
//  WizardWar
//
//  Created by Dallin Skinner on 5/17/13.
//  Copyright (c) 2013 WizardWar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "Units.h"

#define FEEDBACK_FADE_TIME 1.3

// Make this an actual CALayer? ... Maybe
@interface DrawingLayer : CCSprite

@property (nonatomic) BOOL castDisabled;

-(id)initWithUnits:(Units*)units;

-(void)addAnchorPoint:(CGPoint)point;
-(void)moveTailPoint:(CGPoint)point;
-(void)clear;
-(void)resetNow;
-(void)hold;

@end
