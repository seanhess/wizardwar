//
//  SpellbookCastDiagramView.m
//  WizardWar
//
//  Created by Sean Hess on 8/20/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellbookCastDiagramView.h"

static CGFloat const kDashedPhase           = (0.0f);
static CGFloat const kDashedLinesLength[]   = {4.0f, 2.0f};
static size_t const kDashedCount            = (2.0f);

@interface SpellbookCastDiagramView ()
@property (nonatomic, strong) UIImageView * backgroundImageView;
@property (nonatomic) CGPoint centerFire;
@property (nonatomic) CGPoint centerAir;
@property (nonatomic) CGPoint centerEarth;
@property (nonatomic) CGPoint centerHeart;
@property (nonatomic) CGPoint centerWater;
@property (nonatomic) CGFloat strokeWidth;
@end

@implementation SpellbookCastDiagramView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
    
}

- (void)initialize {
    // Initialization code
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.backgroundImageView.image = [UIImage imageNamed:@"cast-diagram.png"];
    self.backgroundImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backgroundImageView];
    [self setOpaque:NO];
    
    self.strokeWidth = 6.0;
}

- (void)calculatePositions {
    self.centerFire  = CGPointMake(self.bounds.size.width*0.495, self.bounds.size.width*0.2);
    self.centerAir   = CGPointMake(self.bounds.size.width*0.145, self.bounds.size.height*0.465);
    self.centerHeart = CGPointMake(self.bounds.size.width*0.846, self.bounds.size.height*0.465);
    self.centerEarth = CGPointMake(self.bounds.size.width*0.29, self.bounds.size.height*0.79);
    self.centerWater = CGPointMake(self.bounds.size.width*0.72, self.bounds.size.height*0.79);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self calculatePositions];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, self.strokeWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    
    CGContextSetLineDash(context, kDashedPhase, kDashedLinesLength, kDashedCount) ;
    
    CGContextMoveToPoint(context, self.centerFire.x, self.centerFire.y);
    
//    CGContextAddLineToPoint(context, self.centerAir.x, self.centerAir.y);
//    CGContextAddLineToPoint(context, self.centerHeart.x, self.centerHeart.y);
//    CGContextAddLineToPoint(context, self.centerWater.x, self.centerWater.y);
//    CGContextAddLineToPoint(context, self.centerEarth.x, self.centerEarth.y);
//    CGContextAddLineToPoint(context, self.centerFire.x, self.centerFire.y);
//    CGContextAddLineToPoint(context, self.centerWater.x, self.centerWater.y);
//    CGContextAddLineToPoint(context, self.centerAir.x, self.centerAir.y);
//    CGContextAddLineToPoint(context, self.centerEarth.x, self.centerEarth.y);
//    CGContextAddLineToPoint(context, self.centerHeart.x, self.centerHeart.y);
//    CGContextAddLineToPoint(context, self.centerFire.x, self.centerFire.y);
    
//    CGContextAddRect(context, rect);
    
    CGContextStrokePath(context);
    
    CGPoint circlePoint = self.centerEarth;
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGFloat radius = 18;
    CGRect circleBounds = CGRectMake(circlePoint.x-radius, circlePoint.y-radius, radius*2, radius*2);
    CGContextStrokeEllipseInRect(context, circleBounds);
}

@end
