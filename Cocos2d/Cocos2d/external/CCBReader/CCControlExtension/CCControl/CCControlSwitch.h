/*
 * CCControlSwitch.h
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

@class CCControlSwitchSprite;

/** @class CCControlSwitch Switch control for Cocos2D. */
@interface CCControlSwitch : CCControl
{
@public
    BOOL                    on_;
    
@protected
    CCControlSwitchSprite   *switchSprite_;
}
/** A Boolean value that determines the off/on state of the switch. */
@property (nonatomic, getter = isOn) BOOL on;

#pragma mark Contructors - Initializers

/** Initializes a switch with a mask sprite, on/off sprites for on/off states and a thumb sprite. */
- (id)initWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite;

/** Creates a switch with a mask sprite, on/off sprites for on/off states and a thumb sprite. */
+ (id)switchWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite;

/** Initializes a switch with a mask sprite, on/off sprites for on/off states, a thumb sprite and an on/off labels. */
- (id)initWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite onLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)onLabel offLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)offLabel;

/** Creates a switch with a mask sprite, on/off sprites for on/off states, a thumb sprite and an on/off labels. */
+ (id)switchWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite onLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)onLabel offLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)offLabel;

#pragma mark - Public Methods

/**
 * Set the state of the switch to On or Off, optionally animating the transition.
 *
 * @param isOn YES if the switch should be turned to the On position; NO if it 
 * should be turned to the Off position. If the switch is already in the 
 * designated position, nothing happens.
 * @param animated YES to animate the “flipping” of the switch; otherwise NO.
 */
- (void)setOn:(BOOL)isOn animated:(BOOL)animated;

@end
