/*
 * CCControl.h
 *
 * Copyright 2011 Yannick Loriot.
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

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/** Number of kinds of control event. */
#define kControlEventTotalNumber 9

/** Kinds of possible events for the control objects. */
enum 
{
    CCControlEventTouchDown           = 1 << 0,    // A touch-down event in the control.
    CCControlEventTouchDragInside     = 1 << 1,    // An event where a finger is dragged inside the bounds of the control.
    CCControlEventTouchDragOutside    = 1 << 2,    // An event where a finger is dragged just outside the bounds of the control. 
    CCControlEventTouchDragEnter      = 1 << 3,    // An event where a finger is dragged into the bounds of the control.
    CCControlEventTouchDragExit       = 1 << 4,    // An event where a finger is dragged from within a control to outside its bounds.
    CCControlEventTouchUpInside       = 1 << 5,    // A touch-up event in the control where the finger is inside the bounds of the control. 
    CCControlEventTouchUpOutside      = 1 << 6,    // A touch-up event in the control where the finger is outside the bounds of the control.
    CCControlEventTouchCancel         = 1 << 7,    // A system event canceling the current touches for the control.
    CCControlEventValueChanged        = 1 << 8      // A touch dragging or otherwise manipulating a control, causing it to emit a series of different values.
};
typedef NSUInteger CCControlEvent;

/** The possible state for a control.  */
enum 
{
    CCControlStateNormal       = 1 << 0, // The normal, or default state of a control—that is, enabled but neither selected nor highlighted.
    CCControlStateHighlighted  = 1 << 1, // Highlighted state of a control. A control enters this state when a touch down, drag inside or drag enter is performed. You can retrieve and set this value through the highlighted property.
    CCControlStateDisabled     = 1 << 2, // Disabled state of a control. This state indicates that the control is currently disabled. You can retrieve and set this value through the enabled property.
    CCControlStateSelected     = 1 << 3  // Selected state of a control. This state indicates that the control is currently selected. You can retrieve and set this value through the selected property.
};
typedef NSUInteger CCControlState;

/** Defines the CCControl block type. 
 *
 * @param sender The sender object- that is call the block.
 * @param event The event which is fired.
 */
typedef void (^CCControlBlock) (id sender, CCControlEvent event);

/*
 * @class
 * CCControl is inspired by the UIControl API class from the UIKit library of 
 * CocoaTouch. It provides a base class for control CCSprites such as CCButton 
 * or CCSlider that convey user intent to the application.
 *
 * The goal of CCControl is to define an interface and base implementation for 
 * preparing action messages and initially dispatching them to their targets when
 * certain events occur.
 *
 * To use the CCControl you have to subclass it.
 */
@interface CCControl : CCLayer <CCRGBAProtocol>
{
@public
    GLubyte             opacity_;
    ccColor3B           color_;
    BOOL                opacityModifyRGB_;
    
    NSInteger           defaultTouchPriority_;
    
    CCControlState      state_;
    
    BOOL                enabled_;
    BOOL                selected_;
    BOOL                highlighted_;
    
@private
    NSMutableDictionary *dispatchTable_;
    NSMutableDictionary *dispatchBlockTable_;
}
/** Conforms to CCRGBAProtocol protocol. */
@property (nonatomic, readwrite) GLubyte opacity;
/** Conforms to CCRGBAProtocol protocol. */
@property (nonatomic, readwrite) ccColor3B color;
/** Conforms to CocosNodeRGBA protocol. */
@property (nonatomic, getter = doesOpacityModifyRGB) BOOL opacityModifyRGB;
/** Changes the priority of the button. The lower the number, the higher the
 priority. */
@property (nonatomic, assign) NSInteger defaultTouchPriority;
/** The current control state constant. */
@property (assign, readonly) CCControlState state;
/** Tells whether the control is enabled. */
@property (nonatomic, getter = isEnabled) BOOL enabled;
/** A Boolean value that determines the control’s selected state. */
@property(nonatomic, getter = isSelected) BOOL selected;
/** A Boolean value that determines whether the control is highlighted. */
@property(nonatomic, getter = isHighlighted) BOOL highlighted;
/** True if all of the controls parents are visible */
@property(nonatomic,readonly) BOOL hasVisibleParents;

#pragma mark CCControl - Preparing and Sending Action Messages

/**
 * Sends action messages for the given control events.
 *
 * @param controlEvents A bitmask whose set flags specify the control events for
 * which action messages are sent. See "CCControlEvent" for bitmask constants.
 */
- (void)sendActionsForControlEvents:(CCControlEvent)controlEvents;

/**
 * Adds a target and action for a particular event (or events) to an internal
 * dispatch table.
 * The action message may optionnaly include the sender and the event as 
 * parameters, in that order.
 * When you call this method, target is not retained.
 *
 * @param target The target object—that is, the object to which the action 
 * message is sent. It cannot be nil. The target is not retained.
 * @param action A selector identifying an action message. It cannot be NULL.
 * @param controlEvents A bitmask specifying the control events for which the 
 * action message is sent. See "CCControlEvent" for bitmask constants.
 */
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(CCControlEvent)controlEvents;

/**
 * Removes a target and action for a particular event (or events) from an 
 * internal dispatch table.
 *
 * @param target The target object—that is, the object to which the action 
 * message is sent. Pass nil to remove all targets paired with action and the
 * specified control events.
 * @param action A selector identifying an action message. Pass NULL to remove
 * all action messages paired with target.
 * @param controlEvents A bitmask specifying the control events associated with
 * target and action. See "CCControlEvent" for bitmask constants.
 */
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(CCControlEvent)controlEvents;

#pragma mark CCControl - Preparing Blocks

/**
 * Sets a block for a particular event (or events) to an internal dispatch 
 * table.
 * 
 * @param block The block to which the action message is sent. If the block is
 * nil, it removes the previous one.
 * @param controlEvents A bitmask specifying the control events for which the 
 * action message is sent. See "CCControlEvent" for bitmask constants.
 */
- (void)setBlock:(CCControlBlock)block forControlEvents:(CCControlEvent)controlEvents;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

/**
 * Returns a point corresponding to the touh location converted into the 
 * control space coordinates.
 */
- (CGPoint)touchLocation:(UITouch *)touch;

/**
 * Returns a boolean value that indicates whether a touch is inside the bounds
 * of the receiver. The given touch must be relative to the world.
 *
 * @param touch A UITouch object that represents a touch.
 *
 * @return YES whether a touch is inside the receiver’s rect.
 */
- (BOOL)isTouchInside:(UITouch *)touch;
#elif __MAC_OS_X_VERSION_MAX_ALLOWED

/**
 * Returns a point corresponding to the event location converted into the
 * control space coordinates.
 */
- (CGPoint)eventLocation:(NSEvent *)event;

/**
 * Returns a boolean value that indicates whether a mouse is inside the bounds
 * of the receiver. The given mouse event must be relative to the world.
 *
 * @param event An NSEvent object representing the event.
 *
 * @return YES whether a mouse event is inside the receiver’s rect.
 */
- (BOOL)isMouseInside:(NSEvent *)event;
#endif

/**
 * Updates the control layout using its current internal state.
 */
- (void)needsLayout;

@end
