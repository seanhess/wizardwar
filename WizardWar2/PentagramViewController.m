//
//  PentagramViewController.m
//  WizardWar
//
//  Created by Dallin Skinner on 5/17/13.
//  Copyright (c) 2013 WizardWar. All rights reserved.
//

#import "PentagramViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PentagramViewController ()

@end

@implementation PentagramViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setMultipleTouchEnabled:YES];
    self.moves = [[NSMutableArray alloc] init];
    DrawingLayer *drawLayer = [[DrawingLayer alloc] initWithFrame:CGRectMake(0, 0, 600, 600)];
    self.drawingLayer = drawLayer;
    self.drawingLayer.points = [[NSMutableArray alloc] init];
    [self.view addSubview:drawLayer];
    
    [self setUpPentagram];
    
}

- (void)setUpPentagram
{
    PentEmblem *fireEmblem = [[PentEmblem alloc]initWithFrame:CGRectMake(267, 37, 46, 47)];
    fireEmblem.type = @"fire";
    fireEmblem.alpha = .4;
    [fireEmblem setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed: @"pentagram-fire.png"]]];
    [self.view addSubview:fireEmblem];
    
    PentEmblem *heartEmblem = [[PentEmblem alloc]initWithFrame:CGRectMake(366, 106, 48, 47)];
    heartEmblem.type = @"heart";
    heartEmblem.alpha = .4;
    [heartEmblem setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed: @"pentagram-heart.png"]]];
    [self.view addSubview:heartEmblem];
    
    PentEmblem *waterEmblem = [[PentEmblem alloc]initWithFrame:CGRectMake(327, 219, 48, 47)];
    waterEmblem.type = @"water";
    waterEmblem.alpha = .4;
    [waterEmblem setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed: @"pentagram-water.png"]]];
    [self.view addSubview:waterEmblem];
    
    PentEmblem *earthEmblem = [[PentEmblem alloc]initWithFrame:CGRectMake(206, 219, 46, 47)];
    earthEmblem.type = @"earth";
    earthEmblem.alpha = .4;
    [earthEmblem setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed: @"pentagram-earth.png"]]];
    [self.view addSubview:earthEmblem];
    
    PentEmblem *windEmblem =[[PentEmblem alloc]initWithFrame:CGRectMake(168, 106, 47, 47)];
    windEmblem.type = @"wind";
    windEmblem.alpha = .4;
    [windEmblem setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed: @"pentagram-wind.png"]]];
    [self.view addSubview:windEmblem];
    
    self.emblems = [NSArray arrayWithObjects: fireEmblem, heartEmblem, waterEmblem, earthEmblem, windEmblem, nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            if(CGRectContainsPoint(emblem.frame, point) && ([self.moves indexOfObject:emblem.type] == NSNotFound))
            {
                self.currentEmblem = emblem;
                emblem.alpha = 1;
                
                [self.moves addObject:emblem.type];
                [self.delegate didSelectElement:self.moves];
                NSLog(@"%@", self.moves);
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
        
        [self.drawingLayer.points addObject: [NSValue valueWithCGPoint:touchPoint]];
        [self.drawingLayer setNeedsDisplay];
        
        [self checkSelectedEmblems:touchPoint];
     
    }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UIView *emblem in self.emblems)
    {
        emblem.alpha = .4;
    }
    
    NSLog(@"%@", self.moves);
    [self.delegate didCastSpell:self.moves];
    
    
    self.drawingLayer.points = [[NSMutableArray alloc] init];
    [self.drawingLayer setNeedsDisplay];
    
    //send out complete set of moves
    self.moves = [[NSMutableArray alloc] init];
    self.currentEmblem = nil;
}

@end
