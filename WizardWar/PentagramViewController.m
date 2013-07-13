//
//  PentagramViewController.m
//  WizardWar
//
//  Created by Dallin Skinner on 5/17/13.
//  Copyright (c) 2013 WizardWar. All rights reserved.
//

#import "PentagramViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Elements.h"
#import "NSArray+Functional.h"

#define RECHARGE_INTERVAL 2.5

@interface PentagramViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *pentagram;

@property (weak, nonatomic) IBOutlet PentEmblem *windEmblem;
@property (weak, nonatomic) IBOutlet PentEmblem *fireEmblem;
@property (weak, nonatomic) IBOutlet PentEmblem *earthEmblem;
@property (weak, nonatomic) IBOutlet PentEmblem *waterEmblem;
@property (weak, nonatomic) IBOutlet PentEmblem *heartEmblem;

@property (weak, nonatomic) DrawingLayer *drawingLayer;

@property (weak, nonatomic) PentEmblem *currentEmblem;
@property (copy, nonatomic) NSArray *emblems;


@end

@implementation PentagramViewController


- (void)viewDidLoad
{
    NSAssert(self.combos, @"PentagramViewController requires combos");
    
    [super viewDidLoad];
    [self.view setMultipleTouchEnabled:YES];
    
    self.view.opaque = NO;
    DrawingLayer *drawLayer = [[DrawingLayer alloc] initWithFrame:self.view.bounds];
    self.drawingLayer = drawLayer;
    drawLayer.opaque = NO;
    drawLayer.backgroundColor = [UIColor clearColor];
    self.drawingLayer.points = [[NSMutableArray alloc] init];
    [self.view insertSubview:self.drawingLayer atIndex:0];
    [self setUpPentagram];
}

- (void)setUpPentagram
{
    self.fireEmblem.element = Fire;
    self.fireEmblem.status = EmblemStatusNormal;
    self.fireEmblem.mana = MAX_MANA;
    
    self.heartEmblem.element = Heart;
    self.heartEmblem.status = EmblemStatusNormal;
    self.heartEmblem.mana = MAX_MANA;
    
    self.waterEmblem.element = Water;
    self.waterEmblem.status = EmblemStatusNormal;
    self.waterEmblem.mana = MAX_MANA;
    
    self.earthEmblem.element = Earth;
    self.earthEmblem.status = EmblemStatusNormal;
    self.earthEmblem.mana = MAX_MANA;
    
    self.windEmblem.element = Air;
    self.windEmblem.status = EmblemStatusNormal;
    self.windEmblem.mana = MAX_MANA;
    
    self.emblems = [NSArray arrayWithObjects: self.fireEmblem, self.heartEmblem, self.waterEmblem, self.earthEmblem, self.windEmblem, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)checkSelectedEmblems:(CGPoint)point {
    
    PentEmblem * emblem = [self.emblems find:^BOOL(PentEmblem*emblem) {
        return CGRectContainsPoint(emblem.frame, point);
    }];
    
    if (emblem && emblem != self.currentEmblem) {
        [self.drawingLayer.points replaceObjectAtIndex: ([self.drawingLayer.points count] - 1) withObject:[NSValue valueWithCGPoint:CGPointMake((emblem.frame.origin.x + (emblem.frame.size.width / 2)), (emblem.frame.origin.y + (emblem.frame.size.height / 2)))]];
        
        [self.drawingLayer.points addObject:[NSValue valueWithCGPoint:point]];
        
        self.currentEmblem = emblem;
        emblem.status = EmblemStatusSelected;
        
        [self.combos moveToElement:emblem.element];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UITouch *touch = obj;
        CGPoint touchPoint = [touch locationInView:self.view];
        [self.drawingLayer.points addObject: [NSValue valueWithCGPoint:touchPoint]];
        [self checkSelectedEmblems:touchPoint];
    }];
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        
        UITouch *touch = obj;
        CGPoint touchPoint = [touch locationInView:self.view];
        
        if ([self.drawingLayer.points count] == 1) {
            // [self.drawingLayer.points replaceObjectAtIndex:1 withObject:[NSValue valueWithCGPoint:touchPoint]];
            [self.drawingLayer.points addObject: [NSValue valueWithCGPoint:touchPoint]];
        } else {
            [self.drawingLayer.points replaceObjectAtIndex:([self.drawingLayer.points count]-1) withObject:[NSValue valueWithCGPoint:touchPoint]];
        }

        [self.drawingLayer setNeedsDisplay];
        
        [self checkSelectedEmblems:touchPoint];
    }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for(PentEmblem *emblem in self.emblems)
    {
        emblem.status = EmblemStatusNormal;
    }
    
    [self.combos releaseElements];
    
    self.drawingLayer.points = [[NSMutableArray alloc] init];
    [self.drawingLayer setNeedsDisplay];
    
    self.currentEmblem = nil;
}

@end
