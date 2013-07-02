/*
 * CCControlSlider
 *
 * Copyright 2011 Yannick Loriot. All rights reserved.
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

#import "CCControl.h"

/** @class CCControlSlider Slider control for Cocos2D. */
@interface CCControlSlider : CCControl 
{  
@public
	float       value_; 
    float       minimumValue_;
    float       maximumValue_;
    
@protected
	// Weak links to children
	CCSprite    *thumbSprite_;
    CCSprite    *progressSprite_;
	CCSprite    *backgroundSprite_;
}  
/** Contains the receiver’s current value. */
@property (nonatomic, assign) float value; 
/** Contains the minimum value of the receiver. 
 * The default value of this property is 0.0. */
@property (nonatomic, assign) float minimumValue;
/** Contains the maximum value of the receiver. 
 * The default value of this property is 1.0. */
@property (nonatomic, assign) float maximumValue;

#pragma mark Contructors - Initializers

/** 
 * Creates slider with a background filename, a progress filename and a 
 * thumb image filename.
 */
+ (id)sliderWithBackgroundFile:(NSString *)bgFile progressFile:(NSString *)progressFile thumbFile:(NSString *)thumbFile;

/** 
 * Creates a slider with a given background sprite and a progress bar and a
 * thumb item.
 *
 * @see initWithBackgroundSprite:progressSprite:thumbSprite:
 */
+ (id)sliderWithBackgroundSprite:(CCSprite *)backgroundSprite progressSprite:(CCSprite *)pogressSprite thumbSprite:(CCSprite *)thumbSprite;

/** 
 * Initializes a slider with a background sprite, a progress bar and a thumb
 * item.
 *
 * @param backgroundSprite  CCSprite, that is used as a background.
 * @param progressSprite    CCSprite, that is used as a progress bar.
 * @param thumbItem         CCSprite, that is used as a thumb.
 */
- (id)initWithBackgroundSprite:(CCSprite *)backgroundSprite progressSprite:(CCSprite *)progressSprite thumbSprite:(CCSprite *)thumbSprite;

#pragma mark - Public Methods

@end  
