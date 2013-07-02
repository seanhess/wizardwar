/*
 * CCControlPotentiometer.m
 *
 * Copyright 2012 Yannick Loriot. All rights reserved.
 * http://yannickloriot.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CCControlPotentiometer.h"

@interface CCControlPotentiometer () 
@property (nonatomic, retain) CCSprite          *thumbSprite;
@property (nonatomic, retain) CCProgressTimer   *progressTimer;
@property (nonatomic, assign) CGPoint           previousLocation;

/** Factorize the event dispath into these methods. */
- (void)potentiometerBegan:(CGPoint)location;
- (void)potentiometerMoved:(CGPoint)location;
- (void)potentiometerEnded:(CGPoint)location;

/** Returns the distance between the point1 and point2. */
- (float)distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2;
/** Returns the angle in degree between line1 and line2. */
- (float)angleInDegreesBetweenLineFromPoint:(CGPoint)beginLineA 
                                    toPoint:(CGPoint)endLineA
                            toLineFromPoint:(CGPoint)beginLineB
                                    toPoint:(CGPoint)endLineB;

@end

@implementation CCControlPotentiometer
@synthesize value               = value_;
@synthesize minimumValue        = minimumValue_;
@synthesize maximumValue        = maximumValue_;
@synthesize thumbSprite         = thumbSprite_;
@synthesize progressTimer       = progressTimer_;
@synthesize previousLocation;

- (void)dealloc
{
    [thumbSprite_       release];
    [progressTimer_     release];
    
    [super              dealloc];
}

+ (id)potentiometerWithTrackFile:(NSString *)backgroundFile progressFile:(NSString *)progressFile thumbFile:(NSString *)thumbFile
{
    // Prepare track for potentiometer
    CCSprite *backgroundSprite      = [CCSprite spriteWithFile:backgroundFile];
    
    // Prepare thumb for potentiometer
	CCSprite *thumbSprite           = [CCSprite spriteWithFile:thumbFile];
    
    // Prepare progress for potentiometer
    CCProgressTimer *progressTimer  = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:progressFile]];
    //progressTimer.type              = kCCProgressTimerTypeRadialCW;

    return [[[self alloc] initWithTrackSprite:backgroundSprite progressSprite:progressTimer thumbSprite:thumbSprite] autorelease];
}

- (id)initWithTrackSprite:(CCSprite *)trackSprite progressSprite:(CCProgressTimer *)progressTimer thumbSprite:(CCSprite *)thumbSprite
{
    if ((self = [super init]))
    {
        self.progressTimer      = progressTimer;
        self.thumbSprite        = thumbSprite;
        thumbSprite.position    = progressTimer_.position;
        
        [self addChild:thumbSprite z:2];
        [self addChild:progressTimer_ z:1];
        [self addChild:trackSprite];
        
        self.contentSize        = trackSprite.contentSize;
        
        // Init default values
        minimumValue_           = 0.0f;
        maximumValue_           = 1.0f;
        self.value              = minimumValue_;
    }
    return self;
}

#pragma mark Properties

- (void)setEnabled:(BOOL)enabled
{
    super.enabled               = enabled;
    
    thumbSprite_.opacity        = (enabled) ? 255.0f : 128.0f;
}

- (void)setValue:(float)value
{
    // set new value with sentinel
    if (value < minimumValue_)
    {
        value                   = minimumValue_;
    }
	
    if (value > maximumValue_) 
    {
        value                   = maximumValue_;
    }
    
    value_                      = value;
    
    // Update thumb and progress position for new value
    float percent               = (value - minimumValue_) / (maximumValue_ - minimumValue_);
    progressTimer_.percentage   = percent * 100.0f;
    thumbSprite_.rotation       = percent * 360.0f;
    
    [self sendActionsForControlEvents:CCControlEventValueChanged];    
}

- (void)setMinimumValue:(float)minimumValue
{
    minimumValue_       = minimumValue;
    
    if (minimumValue_ >= maximumValue_)
    {
        maximumValue_   = minimumValue_ + 1.0f;
    }
    
    self.value          = maximumValue_;
}

- (void)setMaximumValue:(float)maximumValue
{
    maximumValue_       = maximumValue;
    
    if (maximumValue_ <= minimumValue_)
    {
        minimumValue_   = maximumValue_ - 1.0f;
    }
    
    self.value          = minimumValue_;
}

#pragma mark CCTargetedTouch Delegate Methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (BOOL)isTouchInside:(UITouch *)touch
{
    CGPoint touchLocation   = [self touchLocation:touch];
    
    float distance          = [self distanceBetweenPoint:progressTimer_.position andPoint:touchLocation];

    return distance < MIN(self.contentSize.width / 2, self.contentSize.height / 2);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isTouchInside:touch]
        || ![self isEnabled])
    {
        return NO;
    }
    
    previousLocation    = [self touchLocation:touch];
    
    [self potentiometerBegan:previousLocation];
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location    = [self touchLocation:touch];

    [self potentiometerMoved:location];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self potentiometerEnded:CGPointZero];
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)isMouseInside:(NSEvent *)event
{
    CGPoint eventLocation   = [self eventLocation:event];
    float distance          = [self distanceBetweenPoint:progressTimer_.position andPoint:eventLocation];
    
    return distance < MIN(self.contentSize.width / 2, self.contentSize.height / 2);
}

- (BOOL)ccMouseDown:(NSEvent*)event
{
    if (![self isMouseInside:event]
        || ![self isEnabled])
    {
        return NO;
    }
	
    CGPoint location = [self eventLocation:event];
    
    [self potentiometerBegan:location];
    
    return YES;
}


- (BOOL)ccMouseDragged:(NSEvent*)event
{
    if (![self isSelected]
        || ![self isEnabled])
    {
		return NO;
    }
	
    CGPoint location = [self eventLocation:event];
	
    [self potentiometerMoved:location];
	
    return YES;
}

- (BOOL)ccMouseUp:(NSEvent*)event
{
    if (![self isSelected]
        || ![self isEnabled])
    {
		return NO;
    }
    
    [self potentiometerEnded:CGPointZero];
	
    return NO;
}

#endif

#pragma mark -
#pragma mark CCControlPotentiometer Public Methods

#pragma mark CCControlPotentiometer Private Methods

- (float)distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2
{
    CGFloat dx = point1.x - point2.x;
    CGFloat dy = point1.y - point2.y;
    return sqrt(dx*dx + dy*dy);
}

- (float)angleInDegreesBetweenLineFromPoint:(CGPoint)beginLineA 
                                    toPoint:(CGPoint)endLineA
                            toLineFromPoint:(CGPoint)beginLineB
                                    toPoint:(CGPoint)endLineB;
{
    CGFloat a = endLineA.x - beginLineA.x;
    CGFloat b = endLineA.y - beginLineA.y;
    CGFloat c = endLineB.x - beginLineB.x;
    CGFloat d = endLineB.y - beginLineB.y;
    
    CGFloat atanA = atan2(a, b);
    CGFloat atanB = atan2(c, d);
    
    // convert radiants to degrees
    return (atanA - atanB) * 180 / M_PI;
}

- (void)potentiometerBegan:(CGPoint)location
{
    self.selected           = YES;
    self.thumbSprite.color  = ccGRAY;
}

- (void)potentiometerMoved:(CGPoint)location
{
    CGFloat angle       = [self angleInDegreesBetweenLineFromPoint:progressTimer_.position
                                                           toPoint:location 
                                                   toLineFromPoint:progressTimer_.position 
                                                           toPoint:previousLocation];
    
    // fix value, if the 12 o'clock position is between location and previousLocation
    if (angle > 180)
    {
        angle -= 360;
    }
    else if (angle < -180)
    {
        angle += 360;
    }

    self.value          += angle / 360.0f * (maximumValue_ - minimumValue_);
    
    previousLocation    = location;
}

- (void)potentiometerEnded:(CGPoint)location
{
    self.thumbSprite.color  = ccWHITE;
    self.selected           = NO;
}

@end
