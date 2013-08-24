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

@protocol PentagramDelegate <NSObject>

-(void)didTapPentagram;

@end

@interface PentagramViewController : UIViewController
@property (weak, nonatomic) id<PentagramDelegate>delegate;
@property (strong, nonatomic) Combos * combos;
@property (strong, nonatomic) DrawingLayer * drawingLayer;
@property (nonatomic) BOOL disabled;
@property (nonatomic) BOOL hidden;
-(void)delayCast:(NSTimeInterval)delay;
//-(void)showHelpMessage;
-(void)attemptedCastButFailedBecauseOfSleep;
@end
