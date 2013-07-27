/*
 * CCControlColourPicker.m
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

#import "CCControlColourPicker.h"

#import "CCControlSaturationBrightnessPicker.h"
#import "CCControlHuePicker.h"
#import "Utils.h"

@interface CCControlColourPicker ()
@property (nonatomic, assign) HSV                                   hsv;
@property (nonatomic, retain) CCSprite                              *background;
@property (nonatomic, retain) CCControlSaturationBrightnessPicker   *colourPicker;
@property (nonatomic, retain) CCControlHuePicker                    *huePicker;

- (void)updateControlPicker;
- (void)updateHueAndControlPicker;

@end

@implementation CCControlColourPicker
@synthesize hsv             = hsv_;
@synthesize background      = background_;
@synthesize colourPicker    = colourPicker_;
@synthesize huePicker       = huePicker_;

- (void)dealloc
{    
    [background_    removeFromParentAndCleanup:YES];
    [huePicker_     removeFromParentAndCleanup:YES];
    [colourPicker_  removeFromParentAndCleanup:YES];

    background_     = nil;
    huePicker_      = nil;
    colourPicker_   = nil;
    
    [super          dealloc];
}

- (id)init
{
	if ((self = [super init]))
	{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        // Cache the sprites
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CCControlColourPickerSpriteSheet.plist"];
		
        // Create the sprite batch node
        CCSpriteBatchNode *spriteSheet  = [CCSpriteBatchNode batchNodeWithFile:@"CCControlColourPickerSpriteSheet.png"];
        [self addChild:spriteSheet];
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
        // Cache the sprites
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CCControlColourPickerSpriteSheet-hd.plist"];
		
        // Create the sprite batch node
        CCSpriteBatchNode *spriteSheet  = [CCSpriteBatchNode batchNodeWithFile:@"CCControlColourPickerSpriteSheet-hd.png"];
        [self addChild:spriteSheet];
#endif
        
        // MIPMAP
        //ccTexParams params              = {GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
        [spriteSheet.texture setAliasTexParameters];
        //[spriteSheet.texture setTexParameters:&params];
        //[spriteSheet.texture generateMipmap];
        
        // Init default color
        hsv_.h                          = 0;
        hsv_.s                          = 0;
        hsv_.v                          = 0;
        
        // Add image
        background_                     = [Utils addSprite:@"menuColourPanelBackground.png" 
                                                  toTarget:spriteSheet 
                                                   withPos:CGPointZero andAnchor:ccp(0.5f, 0.5f)];
        CGPoint backgroundPointZero     = ccpSub(background_.position, ccp (background_.contentSize.width / 2, 
                                                                            background_.contentSize.height / 2));
        
        // Setup panels
        CGFloat hueShift                = 16;
        CGFloat colourShift             = 56;
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            hueShift                    = 8;
            colourShift                 = 28;
        }
#endif
        
        huePicker_                      = [[CCControlHuePicker alloc] initWithTarget:spriteSheet 
                                                                             withPos:ccp(backgroundPointZero.x + hueShift, 
                                                                                         backgroundPointZero.y + hueShift)];
        colourPicker_                   = [[CCControlSaturationBrightnessPicker alloc] initWithTarget:spriteSheet 
                                                                          withPos:ccp(backgroundPointZero.x + colourShift, 
                                                                                      backgroundPointZero.y + colourShift)];
        
        // Setup events
		[huePicker_ addTarget:self action:@selector(hueSliderValueChanged:) forControlEvents:CCControlEventValueChanged];
		[colourPicker_ addTarget:self action:@selector(colourSliderValueChanged:) forControlEvents:CCControlEventValueChanged];
        
        // Set defaults
        [self updateHueAndControlPicker];
        
        [self addChild:huePicker_];
        [self addChild:colourPicker_];
        
        // Set content size
        [self setContentSize:[background_ contentSize]];
	}
	return self;
}

+ (id)colorPicker
{
    return [[[self alloc] init] autorelease];
}

- (void)setColor:(ccColor3B)color
{
    color_      = color;
    
    RGBA rgba;
    rgba.r      = color.r / 255.0f;
    rgba.g      = color.g / 255.0f;
    rgba.b      = color.b / 255.0f;
    rgba.a      = 1.0f;
    
    hsv_        = [CCColourUtils HSVfromRGB:rgba];

    [self updateHueAndControlPicker];
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled           = enabled;
    
    huePicker_.enabled      = enabled;
    colourPicker_.enabled   = enabled;
}

#pragma mark -
#pragma mark CCControlColourPicker Public Methods

#pragma mark CCControlColourPicker Private Methods

- (void)updateControlPicker
{
    [huePicker_ setHue:hsv_.h];
    [colourPicker_ updateWithHSV:hsv_];
}

- (void)updateHueAndControlPicker
{
    [huePicker_ setHue:hsv_.h];
    [colourPicker_ updateWithHSV:hsv_];
    [colourPicker_ updateDraggerWithHSV:hsv_];
}

#pragma mark - Callback Methods

- (void)hueSliderValueChanged:(CCControlHuePicker *)sender
{
    hsv_.h      = sender.hue;

    // Update the value
    RGBA rgb    = [CCColourUtils RGBfromHSV:hsv_];
    color_      = ccc3(rgb.r * 255.0f, rgb.g * 255.0f, rgb.b * 255.0f);
    
	// Send CCControl callback
	[self sendActionsForControlEvents:CCControlEventValueChanged];
    [self updateControlPicker];
}

- (void)colourSliderValueChanged:(CCControlSaturationBrightnessPicker *)sender
{
    hsv_.s      = sender.saturation;
    hsv_.v      = sender.brightness;

    // Update the value
    RGBA rgb    = [CCColourUtils RGBfromHSV:hsv_];
    color_      = ccc3(rgb.r * 255.0f, rgb.g * 255.0f, rgb.b * 255.0f);
    
    // Send CCControl callback
    [self sendActionsForControlEvents:CCControlEventValueChanged];
}

#pragma mark -
#pragma mark CCTargetedTouch Delegate Methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return NO;
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (BOOL)ccMouseDown:(NSEvent *)event
{
    return NO;
}

#endif

@end
