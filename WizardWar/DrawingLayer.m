



//
//  DrawingLayer.m
//  WizardWar
//
//  Created by Dallin Skinner on 5/17/13.
//  Copyright (c) 2013 WizardWar. All rights reserved.
//

#import "DrawingLayer.h"
#import "AppStyle.h"
#import <QuartzCore/QuartzCore.h>
#import "NSArray+Functional.h"

// LINE SEGMENT
@interface LineSegment : NSObject
@property (nonatomic) CGPoint start;
@property (nonatomic) CGPoint end;
-(BOOL)isEqualToSegment:(LineSegment*)segment;
@end

@implementation LineSegment
-(BOOL)isEqualToSegment:(LineSegment *)segment {
    return (CGPointEqualToPoint(self.start, segment.start) && CGPointEqualToPoint(self.end, segment.end))
    || (CGPointEqualToPoint(self.start, segment.end) && CGPointEqualToPoint(self.end, segment.start));
}

@end













@interface DrawingLayer ()
@property (nonatomic) CGPoint tailPoint;
@property (nonatomic) CGPoint anchorPoint;
@property (nonatomic) CGPoint nextAnchorPoint;

@property (nonatomic, strong) CALayer * anchorLayer;
@property (nonatomic, strong) NSMutableArray * lineSegments;
@end

@implementation DrawingLayer

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.lineColor = [UIColor whiteColor];
        self.lineSegments = [NSMutableArray array];
    }
    return self;
}


-(void)setCastDisabled:(BOOL)castDisabled {
    if (castDisabled)
        self.lineColor = [AppStyle redErrorColor];
    else
        self.lineColor = [UIColor whiteColor];
    
    [self setNeedsDisplay];
}

// as touches move, you just need to change the current tail point
// does not create a segment though!
- (void)addAnchorPoint:(CGPoint)point {
//    [self.points addObject:[NSValue valueWithCGPoint:point]];
    
    self.tailPoint = CGPointZero;
    
    if (![self isPointSet:self.anchorPoint]) {
        self.anchorPoint = point;
        return;
    }
    
    else {
        LineSegment * segment = [LineSegment new];
        segment.start = self.anchorPoint;
        segment.end = point;
        if ([self addLineSegment:segment])
            [self setNeedsDisplay];
        self.anchorPoint = point;
    }
    
}

- (BOOL)isPointSet:(CGPoint)point {
    return !CGPointEqualToPoint(point, CGPointZero);
}

- (void)moveTailPoint:(CGPoint)point {
    self.tailPoint = point;
    [self setNeedsDisplay];
}

- (BOOL)addLineSegment:(LineSegment*)segment {
    if (![self isSegmentDrawn:segment]) {
        [self.lineSegments addObject:segment];
        return YES;
    }
    return NO;
}

- (BOOL)isSegmentDrawn:(LineSegment*)segment {
    LineSegment * existing = [self.lineSegments find:^BOOL(LineSegment*s) {
        return [s isEqualToSegment:segment];
    }];
    return (existing != nil);
}

// you don't need to clear ANYTHING unless you actually clear
// Add multiple layers, and draw to the other one

// maybe only slow because drawing the same segment over and over?
// good way to just draw the one

// Save the existing stuff on another layer

// Now, I need to SAVE the drawing from anchor to anchor

// DRAW the segments on another layer and only change when the segments change?

// The problem is drawing these in UIView vs cocos2d I think
// it practically pauses cocos2d

// nothing to do with anything. 
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
	CGContextSetLineWidth(context, 4.0);

    CGContextBeginPath(context);
//    if ([self isPointSet:self.anchorPoint] && [self isPointSet:self.tailPoint]) {
//        CGContextMoveToPoint(context, self.anchorPoint.x, self.anchorPoint.y);
//        CGContextAddLineToPoint(context, self.tailPoint.x, self.tailPoint.y);
//    }
    
    // draws all activated segments, and
    
    NSLog(@"DRAWING %i", self.lineSegments.count);
    
    for (LineSegment * segment in self.lineSegments) {
        [self context:context drawSegment:segment];
    }
    
    if ([self isPointSet:self.tailPoint])
        [self context:context drawFrom:self.anchorPoint to:self.tailPoint];
    
//    if([self.points count] > 0)
//    {
//        CGPoint startingPoint = [self.points[0] CGPointValue];
//        CGContextMoveToPoint(context, startingPoint.x, startingPoint.y);
//        
//        for (int i = 1; i < self.points.count; i++) {
//            NSValue * value = self.points[i];
//            CGPoint point = [value CGPointValue];
//            CGContextAddLineToPoint(context, point.x, point.y);
//        }
//        
//        if (!CGPointEqualToPoint(self.tailPoint, CGPointZero))
//            CGContextAddLineToPoint(context, self.tailPoint.x, self.tailPoint.y);
//    }
    
	CGContextStrokePath(context);
    
//    self.anchorPoint = self.nextAnchorPoint;    
}

- (void)context:(CGContextRef)context drawSegment:(LineSegment*)segment {
    [self context:context drawFrom:segment.start to:segment.end];
}

- (void)context:(CGContextRef)context drawFrom:(CGPoint)from to:(CGPoint)to {
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
}

@end



@interface LineLayer : CALayer
@end

@implementation LineLayer
@end




