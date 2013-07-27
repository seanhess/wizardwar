/*
 * CCControlStepper.h
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

typedef enum
{
    kCCControlStepperPartMinus,
    kCCControlStepperPartPlus,
    kCCControlStepperPartNone,
} CCControlStepperPart;

@interface CCControlStepper : CCControl
{
@public
    double                  value_;
    BOOL                    continuous_;
    BOOL                    autorepeat_;
    BOOL                    wraps_;
    double                  minimumValue_;
    double                  maximumValue_;
    double                  stepValue_;
        
@protected
    // Weak links to children
	CCSprite                *minusSprite_;
    CCSprite                *plusSprite_;
    CCLabelTTF              *minusLabel_;
    CCLabelTTF              *plusLabel_;
    
    BOOL                    touchInsideFlag_;
    CCControlStepperPart    touchedPart_;
    NSInteger               autorepeatCount_;
}
/** The numeric value of the stepper. */
@property (nonatomic) double value;
/** The continuous vs. noncontinuous state of the stepper. */
@property (nonatomic, getter=isContinuous) BOOL continuous;
/** The automatic vs. nonautomatic repeat state of the stepper. */
@property (nonatomic) BOOL autorepeat;
/** The wrap vs. no-wrap state of the stepper. */
@property (nonatomic) BOOL wraps;
/** The lowest possible numeric value for the stepper. */
@property (nonatomic) double minimumValue;
/** The highest possible numeric value for the stepper. */
@property (nonatomic) double maximumValue;
/** The step, or increment, value for the stepper. */
@property (nonatomic) double stepValue;

#pragma mark Contructors - Initializers

- (id)initWithMinusSprite:(CCSprite *)minusSprite plusSprite:(CCSprite *)plusSprite;
+ (id)stepperWithMinusSprite:(CCSprite *)minusSprite plusSprite:(CCSprite *)plusSprite;

#pragma mark - Public Methods

@end
