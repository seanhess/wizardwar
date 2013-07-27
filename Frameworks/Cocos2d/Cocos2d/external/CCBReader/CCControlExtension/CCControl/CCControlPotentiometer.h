/*
 * CCControlPotentiometer.h
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

#import "CCControl.h"

/** @class CCControlPotentiometer Potentiometer control for Cocos2D. */
@interface CCControlPotentiometer : CCControl
{
@public
    float           value_; 
    float           minimumValue_;
    float           maximumValue_;
    
@protected
    CCSprite        *thumbSprite_;
    CCProgressTimer *progressTimer_;
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
 * Creates potentiometer with a track filename and a progress filename.
 */
+ (id)potentiometerWithTrackFile:(NSString *)backgroundFile progressFile:(NSString *)progressFile thumbFile:(NSString *)thumbFile;

/** 
 * Initializes a potentiometer with a track sprite and a progress bar.
 *
 * @param trackSprite CCSprite, that is used as a background.
 * @param progressSprite CCProgressTimer, that is used as a progress bar.
 */
- (id)initWithTrackSprite:(CCSprite *)trackSprite progressSprite:(CCProgressTimer *)progressTimer thumbSprite:(CCSprite *)thumbSprite;

#pragma mark - Public Methods

@end
