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

@interface PentagramViewController ()
@property (weak, nonatomic) IBOutlet PentEmblem *windEmblem;
@property (weak, nonatomic) IBOutlet PentEmblem *fireEmblem;
@property (weak, nonatomic) IBOutlet PentEmblem *earthEmblem;
@property (weak, nonatomic) IBOutlet PentEmblem *waterEmblem;
@property (weak, nonatomic) IBOutlet PentEmblem *heartEmblem;
@end

@implementation PentagramViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setMultipleTouchEnabled:YES];
    self.moves = [[NSMutableArray alloc] init];
    
    self.view.opaque = NO;
    DrawingLayer *drawLayer = [[DrawingLayer alloc] initWithFrame:self.view.bounds];
    self.drawingLayer = drawLayer;
    drawLayer.opaque = NO;
    drawLayer.backgroundColor = [UIColor clearColor];
    self.drawingLayer.points = [[NSMutableArray alloc] init];
    [self.view insertSubview:self.drawingLayer atIndex:0];
    [self setUpPentagram];
}

- (void)viewDidLayoutSubviews
{
    NSLog(@"pentagram layed out subviews");
    NSLog(@"width: %f", self.view.bounds.size.width);
}

- (void)setUpPentagram
{
    self.fireEmblem.elementId = FireId;
    self.fireEmblem.alpha = .4;
    
    self.heartEmblem.elementId = HeartId;
    self.heartEmblem.alpha = .4;
    
    self.waterEmblem.elementId = WaterId;
    self.waterEmblem.alpha = .4;
    
    self.earthEmblem.elementId = EarthId;
    self.earthEmblem.alpha = .4;
    
    self.windEmblem.elementId = AirId;
    self.windEmblem.alpha = .4;
    
    self.emblems = [NSArray arrayWithObjects: self.fireEmblem, self.heartEmblem, self.waterEmblem, self.earthEmblem, self.windEmblem, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSLog(@"orientation changed %d", fromInterfaceOrientation);
    if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)) {
        NSLog(@"layout here!");
    }
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
                
//                NSLog(@"%f, %f", emblem.frame.origin.x, emblem.frame.origin.y);
                
                [self.drawingLayer.points replaceObjectAtIndex: ([self.drawingLayer.points count] - 1) withObject:[NSValue valueWithCGPoint:CGPointMake((emblem.frame.origin.x + (emblem.frame.size.width / 2)), (emblem.frame.origin.y + (emblem.frame.size.height / 2)))]];
                
                [self.drawingLayer.points addObject:[NSValue valueWithCGPoint:point]];
                
//                NSLog(@"%@", self.drawingLayer.points);
                self.currentEmblem = emblem;
                emblem.alpha = 1;
                
                [self.moves addObject:emblem.elementId];
                [self.delegate didSelectElement:self.moves];
//                NSLog(@"%@", self.moves);
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
    for(UIView *emblem in self.emblems)
    {
        emblem.alpha = .4;
    }
    
//    NSLog(@"%@", self.moves);
    [self.delegate didCastSpell:self.moves];
    
    
    self.drawingLayer.points = [[NSMutableArray alloc] init];
    [self.drawingLayer setNeedsDisplay];
    
    //send out complete set of moves
    self.moves = [[NSMutableArray alloc] init];
    self.currentEmblem = nil;
}

@end
