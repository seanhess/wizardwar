//
//  DrawingLayer.m
//  WizardWar
//
//  Created by Dallin Skinner on 5/17/13.
//  Copyright (c) 2013 WizardWar. All rights reserved.
//

#import "DrawingLayer.h"

@implementation DrawingLayer

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);
    // Drawing lines with a white stroke color
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
	// Draw them with a 2.0 stroke width so they are a bit more visible.
	CGContextSetLineWidth(context, 4.0);
//	NSLog(@"%@", self.points);
    
    if([self.points count] > 0)
    {
        CGPoint point = [[self.points objectAtIndex:0] CGPointValue];
        CGContextMoveToPoint(context, point.x, point.y);
    }
    
    
    for(NSValue *value in self.points)
    {
        CGPoint point = [value CGPointValue];
        
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    
	// Draw a single line from left to right
	
//	CGContextAddLineToPoint(context, 310.0, 30.0);
	CGContextStrokePath(context);
//    self.points = [[NSMutableArray alloc] init];
}


@end
