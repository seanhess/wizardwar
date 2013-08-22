//
//  SpellbookCastDiagramView.m
//  WizardWar
//
//  Created by Sean Hess on 8/20/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellbookCastDiagramView.h"
#import "SpellEffectService.h"
#import "Elements.h"
#import "NSArray+Functional.h"

static CGFloat const kDashedPhase           = (0.0f);
static CGFloat const kDashedLinesLength[]   = {4.0f, 2.0f};
static size_t const kDashedCount            = (2.0f);


@interface CastSegmentPoints : NSObject
@property (nonatomic) CGPoint start;
@property (nonatomic) CGPoint end;
@end

@implementation CastSegmentPoints
@end



@interface SpellbookCastDiagramView ()
@property (nonatomic, strong) UIImageView * backgroundImageView;
@property (nonatomic) CGPoint centerFire;
@property (nonatomic) CGPoint centerAir;
@property (nonatomic) CGPoint centerEarth;
@property (nonatomic) CGPoint centerHeart;
@property (nonatomic) CGPoint centerWater;
@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic, strong) SpellInfo * info;
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

- (void)setRecord:(SpellRecord *)record {
    _record = record;
    self.info = [SpellEffectService.shared infoForType:record.type];
}

- (void)calculatePositions {
    self.centerAir   = CGPointMake(self.bounds.size.width*0.495, self.bounds.size.width*0.2);
    self.centerFire  = CGPointMake(self.bounds.size.width*0.145, self.bounds.size.height*0.465);
    self.centerHeart = CGPointMake(self.bounds.size.width*0.846, self.bounds.size.height*0.465);
    self.centerEarth = CGPointMake(self.bounds.size.width*0.29, self.bounds.size.height*0.79);
    self.centerWater = CGPointMake(self.bounds.size.width*0.72, self.bounds.size.height*0.79);
}

- (CGPoint)pointForElement:(ElementType)element {
    if (element == Fire) return self.centerFire;
    if (element == Air) return self.centerAir;
    if (element == Earth) return self.centerEarth;
    if (element == Water) return self.centerWater;
    else return self.centerHeart;
}

- (NSArray*)allPoints:(Combo*)combo {
    // convert to an array of elements, then map into points
    return [[self allSegments:combo] map:^(ComboSegment * segment) {
        CastSegmentPoints * points = [CastSegmentPoints new];
        points.start = [self pointForElement:segment.start];
        points.end = [self pointForElement:segment.end];
        return points;
    }];
}

- (NSArray*)segmentsFromElements:(NSArray*)elements {
    NSMutableArray * segments = [NSMutableArray array];
    ElementType lastElement = ElementTypeNone;
    for (NSNumber * elementNumber in elements) {
        ElementType element = [elementNumber intValue];
        if (lastElement) {
            ComboSegment * segment = [ComboSegment new];
            segment.start = lastElement;
            segment.end = element;
            [segments addObject:segment];
        }
        lastElement = element;
    }
    return segments;
}

- (NSArray*)allSegments:(Combo*)combo {
    if (combo.segments) return combo.segments.segmentsArray;
    if (combo.orderedElements) return [self segmentsFromElements:combo.orderedElements];
    
    NSMutableArray * elements = [NSMutableArray array];
    
    // Make a selectedElements based on everything else
    ComboSelectedElements * selected = combo.selectedElements;
    if (combo.startElement) {
        // it's only not defined for a basic5 combo
        // so set them all to true
        selected = [ComboSelectedElements new];
        selected.fire = YES;
        selected.air = YES;
        selected.water = YES;
        selected.heart = YES;
        selected.earth = YES;
    }
    
    // Now add each selected one to the array
    if (selected.air)   [elements addObject:@(Air)];
    if (selected.heart) [elements addObject:@(Heart)];
    if (selected.water) [elements addObject:@(Water)];
    if (selected.earth) [elements addObject:@(Earth)];
    if (selected.fire)  [elements addObject:@(Fire)];
    
    // Select a start element.
    // Walk backwards on the list, as long as things are selected
    ElementType startElement = combo.startElement;
    if (!combo.startElement) {
        startElement = Air;
        if (selected.fire) {
            startElement = Fire;
            if (selected.earth) {
                startElement = Earth;
                if (selected.water) {
                    startElement = Water;
                    if (selected.heart) {
                        startElement = Heart;
                    }
                }
            }
        }
    }
    
    // Sort by clockwise distance
    NSArray * sorted = [elements sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ElementType one = [obj1 intValue];
        ElementType two = [obj2 intValue];
        NSInteger distanceOne = [self clockwiseDistance:one fromStart:startElement];
        NSInteger distanceTwo = [self clockwiseDistance:two fromStart:startElement];
        if (distanceOne < distanceTwo) return NSOrderedAscending;
        return NSOrderedDescending;
    }];
    
    return [self segmentsFromElements:sorted];
}

-(NSInteger)clockwiseDistance:(ElementType)element fromStart:(ElementType)start {
    NSInteger distance = element - start;
    if (distance < 0) distance = 5+distance;
    return distance;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self calculatePositions];
    Combo * combo = self.info.combo;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.strokeWidth);
    CGContextSetLineDash(context, kDashedPhase, kDashedLinesLength, kDashedCount);

    // DRAW THE CIRCLE
    ElementType startElement = ElementTypeNone;
    if (combo.startElement)
        startElement = combo.startElement;
    else if (combo.orderedElements.count)
        startElement = [combo.orderedElements[0] intValue];
    
    if (startElement) {
        CGPoint circlePoint = [self pointForElement:startElement];
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        CGFloat radius = 18;
        CGRect circleBounds = CGRectMake(circlePoint.x-radius, circlePoint.y-radius, radius*2, radius*2);
        CGContextStrokeEllipseInRect(context, circleBounds);
    }
    
    // Now, start at the "first one"
    // Hmm, I need an array of elements, always, I think
    // it would be better to return a series of points, a little different
    // start -> finish
    
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    
    NSArray * segments = [self allPoints:combo];
    for (CastSegmentPoints * segment in segments) {
        CGContextMoveToPoint(context, segment.start.x, segment.start.y);
        CGContextAddLineToPoint(context, segment.end.x, segment.end.y);
    }
    
    CGContextStrokePath(context);
    
}

@end
