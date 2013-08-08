//
//  WWViewController.h
//  WizardWar
//
//  Created by Dallin Skinner on 5/17/13.
//  Copyright (c) 2013 WizardWar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PentEmblem.h"
#import "DrawingLayer.h"
#import "Combos.h"
#import <DACircularProgressView.h>

@interface PentagramViewController : UIViewController
@property (strong, nonatomic) Combos * combos;
@property (strong, nonatomic) DrawingLayer * drawingLayer;
-(void)delayCast:(NSTimeInterval)delay;
-(void)showHelpMessage;
@end
