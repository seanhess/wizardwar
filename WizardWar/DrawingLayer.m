



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
#import <OpenGLES/EAGL.h>

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
@property (strong, nonatomic) UIColor * lineColor;
@property (strong, nonatomic) Units * units;
@property (nonatomic, strong) CCAction * fadeAction;

//@property (nonatomic, strong) NSMutableArray * lineSegments;
@property (nonatomic, strong) NSMutableArray * points;
@end

@implementation DrawingLayer

- (id)initWithUnits:(Units *)units {
    self = [super init];
    if (self) {
        // Initialization code
        self.lineColor = [UIColor whiteColor];
        self.points = [NSMutableArray array];
        self.units = units;
    }
    return self;
}


-(void)setCastDisabled:(BOOL)castDisabled {
    if (castDisabled)
        self.lineColor = [AppStyle redErrorColor];
    else
        self.lineColor = [UIColor whiteColor];
    
//    [self setNeedsDisplay];
}

// GAH! need to convert points, taking the contentScaleFactor into account
// well, not impossible, I suppose

// as touches move, you just need to change the current tail point
// does not create a segment though!
- (void)addAnchorPoint:(CGPoint)point {
    [self cancelFadeAndReset];    
    CGPoint converted = [self convertPoint:point];
    [self.points addObject:[NSValue valueWithCGPoint:converted]];
    self.tailPoint = CGPointZero;
    
//    self.tailPoint = CGPointZero;
//    
//    if (![self isPointSet:self.anchorPoint]) {
//        self.anchorPoint = point;
//        return;
//    }
//    
//    else {
//        LineSegment * segment = [LineSegment new];
//        segment.start = self.anchorPoint;
//        segment.end = point;
//        if ([self addLineSegment:segment])
//            [self setNeedsDisplay];
//        self.anchorPoint = point;
//    }
    
}

- (CGPoint)convertPoint:(CGPoint)point {
    CGSize size = [CCDirector sharedDirector].view.bounds.size;
    CGPoint converted = CGPointMake(point.x/self.units.scaleModifier, (size.height - point.y)/self.units.scaleModifier);
    return converted;
}

- (void)clear {
    self.fadeAction = [CCFadeTo actionWithDuration:FEEDBACK_FADE_TIME opacity:0];
    [self runAction:self.fadeAction];
}

-(void)hold {
    [self stopAction:self.fadeAction];
}

- (BOOL)isPointSet:(CGPoint)point {
    return !CGPointEqualToPoint(point, CGPointZero);
}

- (void)moveTailPoint:(CGPoint)point {
    [self cancelFadeAndReset];
//    self.tailPoint = point;
    CGPoint converted = [self convertPoint:point];
    self.tailPoint = converted;
//    [self setNeedsDisplay];
}

- (void)cancelFadeAndReset {
    if (self.fadeAction) {
        [self resetNow];
    }
}

- (void)resetNow {
    [self stopAction:self.fadeAction];
    self.points = [NSMutableArray array];
    self.opacity = 255;
    self.fadeAction = nil;
}



- (void)draw {
    
//    glEnable(GL_LINE_SMOOTH);
//    glLineWidth(lineHeight); // change this as you see fit
//    glColor4ub(255,255,255,255); // change these as you see fit :)
    
    // set line smoothing
//    glEnable(GL_LINE_SMOOTH);
    
    // set line width
    glLineWidth(5.0f * [CCDirector sharedDirector].view.contentScaleFactor);
    
    // set line color.
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    ccDrawColor4B(255, 255, 255, self.opacity);
    
//    ccDrawLine(ccp(100,100), ccp(100, 200));
//    ccDrawLine(ccp(100,200), ccp(200, 200));
//    ccDrawLine(ccp(200,200), ccp(200, 100));
//    ccDrawLine(ccp(200,100), ccp(100, 100));
//    return;
    
    if([self.points count] > 0)
    {
        CGPoint origin = [self.points[0] CGPointValue];

        for (int i = 1; i < self.points.count; i++) {
            NSValue * value = self.points[i];
            CGPoint point = [value CGPointValue];
            ccDrawLine(origin, point);
            origin = point;
        }

        if (!CGPointEqualToPoint(self.tailPoint, CGPointZero))
            ccDrawLine(origin, self.tailPoint);
    }
}

//- (BOOL)addLineSegment:(LineSegment*)segment {
//    if (![self isSegmentDrawn:segment]) {
//        [self.lineSegments addObject:segment];
//        return YES;
//    }
//    return NO;
//}
//
//- (BOOL)isSegmentDrawn:(LineSegment*)segment {
//    LineSegment * existing = [self.lineSegments find:^BOOL(LineSegment*s) {
//        return [s isEqualToSegment:segment];
//    }];
//    return (existing != nil);
//}


//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
//	CGContextSetLineWidth(context, 4.0);
//
//    CGContextBeginPath(context);
////    if ([self isPointSet:self.anchorPoint] && [self isPointSet:self.tailPoint]) {
////        CGContextMoveToPoint(context, self.anchorPoint.x, self.anchorPoint.y);
////        CGContextAddLineToPoint(context, self.tailPoint.x, self.tailPoint.y);
////    }
//    
//    // draws all activated segments, and
//    
//    NSLog(@"DRAWING %i", self.lineSegments.count);
//    
//    for (LineSegment * segment in self.lineSegments) {
//        [self context:context drawSegment:segment];
//    }
//    
//    if ([self isPointSet:self.tailPoint])
//        [self context:context drawFrom:self.anchorPoint to:self.tailPoint];
//    
////    if([self.points count] > 0)
////    {
////        CGPoint startingPoint = [self.points[0] CGPointValue];
////        CGContextMoveToPoint(context, startingPoint.x, startingPoint.y);
////        
////        for (int i = 1; i < self.points.count; i++) {
////            NSValue * value = self.points[i];
////            CGPoint point = [value CGPointValue];
////            CGContextAddLineToPoint(context, point.x, point.y);
////        }
////        
////        if (!CGPointEqualToPoint(self.tailPoint, CGPointZero))
////            CGContextAddLineToPoint(context, self.tailPoint.x, self.tailPoint.y);
////    }
//    
//	CGContextStrokePath(context);
//    
////    self.anchorPoint = self.nextAnchorPoint;    
//}

//- (void)context:(CGContextRef)context drawSegment:(LineSegment*)segment {
//    [self context:context drawFrom:segment.start to:segment.end];
//}
//
//- (void)context:(CGContextRef)context drawFrom:(CGPoint)from to:(CGPoint)to {
//    CGContextMoveToPoint(context, from.x, from.y);
//    CGContextAddLineToPoint(context, to.x, to.y);
//}

@end



@interface LineLayer : CALayer
@end

@implementation LineLayer
@end




