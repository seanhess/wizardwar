/*
 * CCControlStepper.m
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

#import "CCControlStepper.h"

#define CCControlStepperLabelColorEnabled   ccc3(55, 55, 55)
#define CCControlStepperLabelColorDisabled  ccc3(147, 147, 147)

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#define CCControlStepperLabelFont           @"CourierNewPSMT"
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
#define CCControlStepperLabelFont           @"Courier New"
#endif

#define kAutorepeatDeltaTime                0.15f
#define kAutorepeatIncreaseTimeIncrement    12

@interface CCControlStepper ()
@property (nonatomic, retain) CCSprite      *minusSprite;
@property (nonatomic, retain) CCSprite      *plusSprite;
@property (nonatomic, retain) CCLabelTTF    *minusLabel;
@property (nonatomic, retain) CCLabelTTF    *plusLabel;

/** Update the layout of the stepper with the given touch location. */
- (void)updateLayoutUsingTouchLocation:(CGPoint)location;

/** Set the numeric value of the stepper. If send is true, the CCControlEventValueChanged is sent. */
- (void)setValue:(double)value sendingEvent:(BOOL)send;

/** Start the autorepeat increment/decrement. */
- (void)startAutorepeat;

/** Stop the autorepeat. */
- (void)stopAutorepeat;

@end

@implementation CCControlStepper
@synthesize minusSprite     = minusSprite_;
@synthesize plusSprite      = plusSprite_;
@synthesize minusLabel      = minusLabel_;
@synthesize plusLabel       = plusLabel_;

@synthesize value           = value_;
@synthesize continuous      = continuous_;
@synthesize autorepeat      = autorepeat_;
@synthesize wraps           = wraps_;
@synthesize minimumValue    = minimumValue_;
@synthesize maximumValue    = maximumValue_;
@synthesize stepValue       = stepValue_;

- (void)dealloc
{
    [self unscheduleAllSelectors];
    
    [minusSprite_   release];
    [plusSprite_    release];
    [minusLabel_    release];
    [plusLabel_     release];
    
    [super          dealloc];
}

- (id)initWithMinusSprite:(CCSprite *)minusSprite plusSprite:(CCSprite *)plusSprite
{
    if ((self = [super init]))
    {
        NSAssert(minusSprite,   @"Minus sprite must be not nil");
        NSAssert(plusSprite,    @"Plus sprite must be not nil");
        
        // Set the default values
        autorepeat_                         = YES;
        continuous_                         = YES;
        minimumValue_                       = 0;
        maximumValue_                       = 100;
        value_                              = 0;
        stepValue_                          = 1;
        wraps_                              = NO;
        self.ignoreAnchorPointForPosition   = NO;
    
        // Add the minus components
        self.minusSprite                    = minusSprite;
		minusSprite_.position               = ccp(minusSprite.contentSize.width / 2, minusSprite.contentSize.height / 2);
		[self addChild:minusSprite_];
        
        self.minusLabel                     = [CCLabelTTF labelWithString:@"-" fontName:CCControlStepperLabelFont fontSize:40];
        minusLabel_.color                   = CCControlStepperLabelColorDisabled;
        minusLabel_.position                = CGPointMake(minusSprite_.contentSize.width / 2, minusSprite_.contentSize.height / 2);
        [minusSprite_ addChild:minusLabel_];
        
        // Add the plus components 
        self.plusSprite                     = plusSprite;
		plusSprite_.position                = ccp(minusSprite.contentSize.width + plusSprite.contentSize.width / 2, 
                                                  minusSprite.contentSize.height / 2);
		[self addChild:plusSprite_];
        
        self.plusLabel                      = [CCLabelTTF labelWithString:@"+" fontName:CCControlStepperLabelFont fontSize:40];
        plusLabel_.color                    = CCControlStepperLabelColorEnabled;
        plusLabel_.position                 = CGPointMake(plusSprite_.contentSize.width / 2, plusSprite_.contentSize.height / 2);
        [plusSprite_ addChild:plusLabel_];
        
        // Defines the content size
        CGRect maxRect                      = CGRectUnion([minusSprite_ boundingBox], [plusSprite_ boundingBox]);
        self.contentSize                    = CGSizeMake(minusSprite_.contentSize.width + plusSprite_.contentSize.height,
                                                         maxRect.size.height);
    }
    return self;
}

+ (id)stepperWithMinusSprite:(CCSprite *)minusSprite plusSprite:(CCSprite *)plusSprite
{
    return [[[self alloc] initWithMinusSprite:minusSprite plusSprite:plusSprite] autorelease];
}

#pragma mark Properties

- (void)setWraps:(BOOL)wraps
{
    wraps_ = wraps;
    
    if (wraps_)
    {
        minusLabel_.color   = CCControlStepperLabelColorEnabled;
        plusLabel_.color    = CCControlStepperLabelColorEnabled;
    }
    
    self.value  = value_;
}

- (void)setMinimumValue:(double)minimumValue
{
    if (minimumValue >= maximumValue_)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Must be numerically less than maximumValue." userInfo:nil];
    }
    
    minimumValue_   = minimumValue;
    self.value      = value_;
}

- (void)setMaximumValue:(double)maximumValue
{
    if (maximumValue <= minimumValue_)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Must be numerically greater than minimumValue." userInfo:nil];
    }
    
    maximumValue_   = maximumValue;
    self.value      = value_;
}

- (void)setValue:(double)value
{
    [self setValue:value sendingEvent:YES];
}

- (void)setStepValue:(double)stepValue
{
    if (stepValue <= 0)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Must be numerically greater than 0." userInfo:nil];  
    }
    
    stepValue_  = stepValue;
}

#pragma mark -
#pragma mark CCControlStepper Public Methods

- (void)setValue:(double)value sendingEvent:(BOOL)send
{
    if (value < minimumValue_)
    {
        value = wraps_ ? maximumValue_ : minimumValue_;
    } else if (value > maximumValue_)
    {
        value = wraps_ ? minimumValue_ : maximumValue_;
    }
    
    value_ = value;
    
    if (!wraps_)
    {
        minusLabel_.color   = (value == minimumValue_) ? CCControlStepperLabelColorDisabled : CCControlStepperLabelColorEnabled;
        plusLabel_.color    = (value == maximumValue_) ? CCControlStepperLabelColorDisabled : CCControlStepperLabelColorEnabled;
    }
    
    if (send)
    {
        [self sendActionsForControlEvents:CCControlEventValueChanged];
    }
}

- (void)startAutorepeat
{
    autorepeatCount_    = -1;
    
    [self schedule:@selector(update:) interval:kAutorepeatDeltaTime repeat:kCCRepeatForever delay:kAutorepeatDeltaTime * 3];
}

/** Stop the autorepeat. */
- (void)stopAutorepeat
{
    [self unschedule:@selector(update:)];
}

- (void)update:(ccTime)dt
{
    autorepeatCount_++;
    
    if ((autorepeatCount_ < kAutorepeatIncreaseTimeIncrement) && (autorepeatCount_ % 3) != 0)
        return;
    
    if (touchedPart_ == kCCControlStepperPartMinus)
    {
        [self setValue:(value_ - stepValue_) sendingEvent:continuous_];
    } else if (touchedPart_ == kCCControlStepperPartPlus)
    {
        [self setValue:(value_ + stepValue_) sendingEvent:continuous_];
    }
}

#pragma mark CCControlStepper Private Methods

- (void)updateLayoutUsingTouchLocation:(CGPoint)location
{
    if (location.x < minusSprite_.contentSize.width
        && value_ > minimumValue_)
    {
        touchedPart_        = kCCControlStepperPartMinus;
        
        minusSprite_.color  = ccGRAY;
        plusSprite_.color   = ccWHITE;
    } else if (location.x >= minusSprite_.contentSize.width
               && value_ < maximumValue_)
    {
        touchedPart_        = kCCControlStepperPartPlus;
        
        minusSprite_.color  = ccWHITE;
        plusSprite_.color   = ccGRAY;
    } else
    {
        touchedPart_        = kCCControlStepperPartNone;
        
        minusSprite_.color  = ccWHITE;
        plusSprite_.color   = ccWHITE;
    }
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isTouchInside:touch]
        || ![self isEnabled])
    {
        return NO;
    }
    
    CGPoint location    = [self touchLocation:touch];
    [self updateLayoutUsingTouchLocation:location];
    
    touchInsideFlag_ = YES;
    
    if (autorepeat_)
    {
        [self startAutorepeat];
    }
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([self isTouchInside:touch])
    {
        CGPoint location    = [self touchLocation:touch];
        [self updateLayoutUsingTouchLocation:location];
        
        if (!touchInsideFlag_)
        {
            touchInsideFlag_    = YES;
            
            if (autorepeat_)
            {
                [self startAutorepeat];
            }
        }
    } else
    {
        touchInsideFlag_    = NO;
        
        touchedPart_        = kCCControlStepperPartNone;
        
        minusSprite_.color  = ccWHITE;
        plusSprite_.color   = ccWHITE;
        
        if (autorepeat_)
        {
            [self stopAutorepeat];
        }
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    minusSprite_.color  = ccWHITE;
    plusSprite_.color   = ccWHITE;
    
    if (autorepeat_)
    {
        [self stopAutorepeat];
    }
    
    if ([self isTouchInside:touch])
    {
        CGPoint location    = [self touchLocation:touch];
        
        self.value += (location.x < minusSprite_.contentSize.width) ? - stepValue_ : stepValue_;
    }
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccMouseDown:(NSEvent *)event
{
    if (![self isMouseInside:event]
        || ![self isEnabled])
    {
        return NO;
    }
    
    CGPoint location    = [self eventLocation:event];
    [self updateLayoutUsingTouchLocation:location];
    
    touchInsideFlag_ = YES;
    
    if (autorepeat_)
    {
        [self startAutorepeat];
    }
    
    return YES;
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{
    if ([self isMouseInside:event])
    {
        CGPoint location    = [self eventLocation:event];
        [self updateLayoutUsingTouchLocation:location];
        
        if (!touchInsideFlag_)
        {
            touchInsideFlag_    = YES;
            
            if (autorepeat_)
            {
                [self startAutorepeat];
            }
        }
    } else
    {
        touchInsideFlag_    = NO;
        
        touchedPart_        = kCCControlStepperPartNone;
        
        minusSprite_.color  = ccWHITE;
        plusSprite_.color   = ccWHITE;
        
        if (autorepeat_)
        {
            [self stopAutorepeat];
        }
    }
    
    return YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
    minusSprite_.color  = ccWHITE;
    plusSprite_.color   = ccWHITE;
    
    if (autorepeat_)
    {
        [self stopAutorepeat];
    }
    
    if ([self isMouseInside:event])
    {
        CGPoint location    = [self eventLocation:event];
        
        self.value += (location.x < minusSprite_.contentSize.width) ? - stepValue_ : stepValue_;
    }
    
	return YES;
}

#endif

@end
