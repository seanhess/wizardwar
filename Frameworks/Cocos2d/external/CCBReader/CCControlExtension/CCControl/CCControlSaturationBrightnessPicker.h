/*
 * CCControlSaturationBrightnessPicker.h
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

#import "CCControl.h"

#import "CCColourUtils.h"

@interface CCControlSaturationBrightnessPicker : CCControl
{
@public
    CGFloat     saturation_, brightness_;
    
@protected
    CCSprite    *background_;
    CCSprite    *overlay_;
    CCSprite    *shadow_;
    CCSprite    *slider_;
    CGPoint     startPos;
    
    int         boxPos;
    int         boxSize;
}
/** Contains the receiver’s current saturation value. */
@property (nonatomic, assign) CGFloat saturation;
/** Contains the receiver’s current brightness value. */
@property (nonatomic, assign) CGFloat brightness;

#pragma mark - Constuctors - Initializers

- (id)initWithTarget:(id)target withPos:(CGPoint)pos;

#pragma mark - Public Methods

- (void)updateWithHSV:(HSV)hsv;
- (void)updateDraggerWithHSV:(HSV)hsv;

@end
