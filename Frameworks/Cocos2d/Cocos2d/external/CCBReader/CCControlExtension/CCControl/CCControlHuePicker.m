/*
 * CCControlHuePicker.m
 *
 * Copyright 2012 Stewart Hamilton-Arrandale.
 * http://creativewax.co.uk
 *
 * Modified by Yannick Loriot.
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

#import "CCControlHuePicker.h"
#import "Utils.h"

@interface CCControlHuePicker ()
@property (nonatomic, retain) CCSprite    *background;
@property (nonatomic, retain) CCSprite    *slider;
@property (nonatomic, assign) CGPoint     startPos;

- (void)updateSliderPosition:(CGPoint)location;
- (BOOL)checkSliderPosition:(CGPoint)location;
    
@end
    
@implementation CCControlHuePicker
@synthesize background      = background_;
@synthesize slider          = slider_;
@synthesize startPos        = startPos_;
@synthesize hue             = hue_;
@synthesize huePercentage   = huePercentage_;

- (void)dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    
    [background_ release];
    [slider_ release];
    
	[super dealloc];
}

- (id)initWithTarget:(id)target withPos:(CGPoint)pos
{
    if ((self = [super init]))
    {
        // Add background and slider sprites
        self.background     = [Utils addSprite:@"huePickerBackground.png" toTarget:target withPos:pos andAnchor:ccp(0, 0)];
        self.slider         = [Utils addSprite:@"colourPicker.png" toTarget:target withPos:pos andAnchor:ccp(0.5f, 0.5f)];
        
        slider_.position    = ccp(pos.x, pos.y + background_.boundingBox.size.height * 0.5f);
        
        startPos_           = pos;
        
        // Sets the default value
        hue_                = 0.0f;
        huePercentage_      = 0.0f;
    }
    return self;
}

- (void)setHue:(CGFloat)hueValue
{
    hue_                = hueValue;
    
    // Set the position of the slider to the correct hue
    // We need to divide it by 360 as its taken as an angle in degrees
    float huePercentage	= hueValue / 360.0f;
    
    // update
    [self setHuePercentage:huePercentage];
}

- (void)setHuePercentage:(CGFloat)hueValueInPercent_
{
    huePercentage_          = hueValueInPercent_;
    hue_                    = hueValueInPercent_ * 360.0f;
    
    // Clamp the position of the icon within the circle
    CGRect backgroundBox    = background_.boundingBox;
    
    // Get the center point of the background image
    float centerX           = startPos_.x + backgroundBox.size.width * 0.5f;
    float centerY           = startPos_.y + backgroundBox.size.height * 0.5f;
    
    // Work out the limit to the distance of the picker when moving around the hue bar
    float limit             = backgroundBox.size.width * 0.5f - 15.0f;
    
    // Update angle
    float angleDeg          = huePercentage_ * 360.0f - 180.0f;
    float angle             = CC_DEGREES_TO_RADIANS(angleDeg);
    
    // Set new position of the slider
    float x                 = centerX + limit * cosf(angle);
    float y                 = centerY + limit * sinf(angle);
    slider_.position        = ccp(x, y);
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled   = enabled;
    
    slider_.opacity = enabled ? 255.0f : 128.0f;
}

#pragma mark -
#pragma mark CCControlHuePicker Public Methods

#pragma mark CCControlHuePicker Private Methods

- (void)updateSliderPosition:(CGPoint)location
{
    // Clamp the position of the icon within the circle
    CGRect backgroundBox    = background_.boundingBox;
    
    // get the center point of the background image
    float centerX           = startPos_.x + backgroundBox.size.width * 0.5f;
    float centerY           = startPos_.y + backgroundBox.size.height * 0.5f;
    
    // Work out the distance difference between the location and center
    float dx                = location.x - centerX;
    float dy                = location.y - centerY;
    
    // Update angle by using the direction of the location
    float angle             = atan2f(dy, dx);
    float angleDeg          = CC_RADIANS_TO_DEGREES(angle) + 180.0f;
    
    // use the position / slider width to determin the percentage the dragger is at
    self.hue                = angleDeg;
    
	// send CCControl callback
    [self sendActionsForControlEvents:CCControlEventValueChanged];
}

- (BOOL)checkSliderPosition:(CGPoint)location
{
    // check that the touch location is within the bounding rectangle before sending updates
	if (CGRectContainsPoint(background_.boundingBox, location))
    {
        [self updateSliderPosition:location];
        
        return YES;
    }
    return NO;
}


#pragma mark -
#pragma mark CCTargetedTouch Delegate Methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isEnabled])
    {
        return NO;
    }
    
    // Get the touch location
    CGPoint touchLocation   = [self touchLocation:touch];
	
    // Check the touch position on the slider
    return [self checkSliderPosition:touchLocation];
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // Get the touch location
    CGPoint touchLocation   = [self touchLocation:touch];
	
    // Check the touch position on the slider
    [self checkSliderPosition:touchLocation];
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccMouseDown:(NSEvent *)event
{
    if (![self isEnabled])
    {
        return NO;
    }
    
    // Get the event location
    CGPoint eventLocation   = [self eventLocation:event];

    // Check the touch position on the slider
    [self checkSliderPosition:eventLocation];

    return NO;
}


- (BOOL)ccMouseDragged:(NSEvent *)event
{
    if (![self isEnabled])
    {
        return NO;
    }
    
	// Get the event location
    CGPoint eventLocation   = [self eventLocation:event];
	
    // Check the touch position on the slider
    [self checkSliderPosition:eventLocation];
    return NO;
}

#endif

@end
