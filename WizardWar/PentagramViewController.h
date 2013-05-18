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

@protocol PentagramDelegate
-(void)didSelectElement:(NSArray *)elements;
-(void)didCastSpell:(NSArray *)elements;
@end

@interface PentagramViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *pentagram;
@property (weak, nonatomic) id<PentagramDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *moves;
@property (copy, nonatomic) NSArray *emblems;

@property (weak, nonatomic) DrawingLayer *drawingLayer;

@property (weak, nonatomic) PentEmblem *currentEmblem;

@end
