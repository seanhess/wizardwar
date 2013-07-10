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
@property (weak, nonatomic) IBOutlet PentEmblem *windEmblem;
@property (weak, nonatomic) IBOutlet PentEmblem *fireEmblem;
@property (weak, nonatomic) IBOutlet PentEmblem *earthEmblem;
@property (weak, nonatomic) IBOutlet PentEmblem *waterEmblem;
@property (weak, nonatomic) IBOutlet PentEmblem *heartEmblem;

@property (strong, nonatomic) NSMutableArray * selectedEmblems;

@property (strong, nonatomic) NSTimer * timer;

@end

@implementation PentagramViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setMultipleTouchEnabled:YES];
    self.moves = [[NSMutableArray alloc] init];
    
    self.selectedEmblems = [NSMutableArray array];
    
    self.view.opaque = NO;
    DrawingLayer *drawLayer = [[DrawingLayer alloc] initWithFrame:self.view.bounds];
    self.drawingLayer = drawLayer;
    drawLayer.opaque = NO;
    drawLayer.backgroundColor = [UIColor clearColor];
    self.drawingLayer.points = [[NSMutableArray alloc] init];
    [self.view insertSubview:self.drawingLayer atIndex:0];
    [self setUpPentagram];
}

//- (void)viewDidLayoutSubviews
//{
//}

- (void)setUpPentagram
{
    self.fireEmblem.elementId = FireId;
    self.fireEmblem.status = EmblemStatusNormal;
    self.fireEmblem.mana = MAX_MANA;
    
    self.heartEmblem.elementId = HeartId;
    self.heartEmblem.status = EmblemStatusNormal;
    self.heartEmblem.mana = MAX_MANA;
    
    self.waterEmblem.elementId = WaterId;
    self.waterEmblem.status = EmblemStatusNormal;
    self.waterEmblem.mana = MAX_MANA;
    
    self.earthEmblem.elementId = EarthId;
    self.earthEmblem.status = EmblemStatusNormal;
    self.earthEmblem.mana = MAX_MANA;
    
    self.windEmblem.elementId = AirId;
    self.windEmblem.status = EmblemStatusNormal;
    self.windEmblem.mana = MAX_MANA;
    
    self.emblems = [NSArray arrayWithObjects: self.fireEmblem, self.heartEmblem, self.waterEmblem, self.earthEmblem, self.windEmblem, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)) {
//    }
//}

- (void)onTimer {
    return;
//    NSArray * disabledEmblems = [self.emblems filter:^BOOL(PentEmblem*emblem) {
//        return emblem.status == EmblemStatusDisabled;
//    }];
    
    [self.emblems forEach:^(PentEmblem * emblem) {
        emblem.mana += 1;
    }];
    
    [self startRecharge];
    
//    NSUInteger numDisabled = disabledEmblems.count;
//    
//    if (numDisabled) {
//        NSUInteger randomIndex = arc4random() % disabledEmblems.count;
//        PentEmblem * emblem = disabledEmblems[randomIndex];
//        emblem.status = EmblemStatusNormal;
//        
//        if (numDisabled > 1) {
//            [self startRecharge];
//        }
//    }
}

- (void)startRecharge {
    return;
    // resets the timer if running
    [self.timer invalidate];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:RECHARGE_INTERVAL target:self selector:@selector(onTimer) userInfo:nil repeats:NO];
}

- (void)checkSelectedEmblems:(CGPoint)point {
    
    if(self.currentEmblem != nil)
    {
        if(!CGRectContainsPoint(self.currentEmblem.frame, point)){
            self.currentEmblem = nil;
        }
    }
    
    if(self.currentEmblem == nil)
    {
        for(PentEmblem *emblem in self.emblems)
        {
//            if(CGRectContainsPoint(emblem.frame, point) && ([self.moves indexOfObject:emblem.type] == NSNotFound))
            if(CGRectContainsPoint(emblem.frame, point) && (![[self.moves lastObject] isEqualToString:emblem.elementId]))
            {
                
                [self.drawingLayer.points replaceObjectAtIndex: ([self.drawingLayer.points count] - 1) withObject:[NSValue valueWithCGPoint:CGPointMake((emblem.frame.origin.x + (emblem.frame.size.width / 2)), (emblem.frame.origin.y + (emblem.frame.size.height / 2)))]];
                
                [self.drawingLayer.points addObject:[NSValue valueWithCGPoint:point]];
                
                self.currentEmblem = emblem;
                emblem.status = EmblemStatusHighlight;
                
                [self.selectedEmblems addObject:emblem];
                [self.moves addObject:emblem.elementId];
                [self.delegate didSelectElement:self.moves];
            }
        }
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
    
    for(PentEmblem *emblem in self.selectedEmblems)
    {
        emblem.status = EmblemStatusNormal;
//        emblem.mana -= 1;
    }
    
    self.selectedEmblems = [NSMutableArray array];
    
    [self startRecharge];
    
//    NSLog(@"%@", self.moves);
    [self.delegate didCastSpell:self.moves];
    
    
    self.drawingLayer.points = [[NSMutableArray alloc] init];
    [self.drawingLayer setNeedsDisplay];
    
    //send out complete set of moves
    self.moves = [[NSMutableArray alloc] init];
    self.currentEmblem = nil;
}

@end
