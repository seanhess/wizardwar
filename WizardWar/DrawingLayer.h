//
//  DrawingLayer.h
//  WizardWar
//
//  Created by Dallin Skinner on 5/17/13.
//  Copyright (c) 2013 WizardWar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

// Make this an actual CALayer? ... Maybe
@interface DrawingLayer : UIView

@property (strong, nonatomic) NSMutableArray *points;
@property (strong, nonatomic) UIColor * lineColor;

@property (nonatomic) BOOL castDisabled;

-(void)addAnchorPoint:(CGPoint)point;
-(void)moveTailPoint:(CGPoint)point;

@end
