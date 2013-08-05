//
//  PentEmblemBackground.m
//  WizardWar
//
//  Created by Sean Hess on 8/5/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "PentEmblemHighlight.h"

@implementation PentEmblemHighlight

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.borderWidth = frame.size.width/15;
        self.borderColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat strokeWidth = self.borderWidth;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    
    CGFloat radius = self.bounds.size.width/2;
    CGRect rrect = self.bounds;
    rrect.size.width = rrect.size.width - strokeWidth*2;
    rrect.size.height = rrect.size.height - strokeWidth*2;
    rrect.origin.x = rrect.origin.x + (strokeWidth / 2);
    rrect.origin.y = rrect.origin.y + (strokeWidth / 2);
    CGFloat width = CGRectGetWidth(rrect);
    CGFloat height = CGRectGetHeight(rrect);
    
    if (radius > width/2.0)
        radius = width/2.0;
    if (radius > height/2.0)
        radius = height/2.0;
    
    CGFloat minx = CGRectGetMinX(rrect);
    CGFloat midx = CGRectGetMidX(rrect);
    CGFloat maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect);
    CGFloat midy = CGRectGetMidY(rrect);
    CGFloat maxy = CGRectGetMaxY(rrect);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke);
}



@end
