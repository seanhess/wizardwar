//
//  DrawingLayer.h
//  WizardWar
//
//  Created by Dallin Skinner on 5/17/13.
//  Copyright (c) 2013 WizardWar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawingLayer : UIView

@property (strong, nonatomic) NSMutableArray *points;
@property (strong, nonatomic) UIColor * lineColor;

@property (nonatomic) BOOL castDisabled;

@end
