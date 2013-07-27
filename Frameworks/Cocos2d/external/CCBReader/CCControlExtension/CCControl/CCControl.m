/*
 * CCControl.m
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

#import "CCControl.h"

@interface CCControl ()
/** 
 * Table of connection between the CCControlEvents and their associated
 * target-actions pairs. For each CCButtonEvents a list of NSInvocation
 * (which contains the target-action pair) is linked.
 */
@property (nonatomic, retain) NSMutableDictionary *dispatchTable;
/** 
 * Table of connection between the CCControlEvents and their associated
 * blocks. For each CCButtonEvents a list of blocks is linked.
 */
@property (nonatomic, retain) NSMutableDictionary *dispatchBlockTable;

/**
 * Adds a target and action for a particular event to an internal dispatch 
 * table.
 * The action message may optionnaly include the sender and the event as 
 * parameters, in that order.
 * When you call this method, target is not retained.
 *
 * @param target The target object—that is, the object to which the action 
 * message is sent. It cannot be nil. The target is not retained.
 * @param action A selector identifying an action message. It cannot be NULL.
 * @param controlEvent A control event for which the action message is sent.
 * See "CCControlEvent" for constants.
 */
- (void)addTarget:(id)target action:(SEL)action forControlEvent:(CCControlEvent)controlEvent;

/**
 * Removes a target and action for a particular event from an internal dispatch
 * table.
 *
 * @param target The target object—that is, the object to which the action 
 * message is sent. Pass nil to remove all targets paired with action and the
 * specified control events.
 * @param action A selector identifying an action message. Pass NULL to remove
 * all action messages paired with target.
 * @param controlEvent A control event for which the action message is sent.
 * See "CCControlEvent" for constants.
 */
- (void)removeTarget:(id)target action:(SEL)action forControlEvent:(CCControlEvent)controlEvent;

/**
 * Returns an NSInvocation object able to construct messages using a given 
 * target-action pair. The invocation may optionnaly include the sender and
 * the event as parameters, in that order.
 *
 * @param target The target object.
 * @param action A selector identifying an action message.
 * @param controlEvent A control events for which the action message is sent.
 * See "CCControlEvent" for constants.
 *
 * @return an NSInvocation object able to construct messages using a given 
 * target-action pair.
 */
- (NSInvocation *)invocationWithTarget:(id)target action:(SEL)action forControlEvent:(CCControlEvent)controlEvent;

/**
 * Returns the NSInvocation list for the given control event. If the list does
 * not exist, it'll create an empty array before returning it.
 *
 * @param controlEvent A control events for which the action message is sent.
 * See "CCControlEvent" for constants.
 *
 * @return the NSInvocation list for the given control event.
 */
- (NSMutableArray *)dispatchListforControlEvent:(CCControlEvent)controlEvent;

#if NS_BLOCKS_AVAILABLE

/**
 * Sets a block for a particular event to an internal dispatch table.
 * 
 * @param block The block to which the action message is sent.
 * @param controlEvent A control events for which the action message is sent.
 * See "CCControlEvent" for constants.
 */
- (void)setBlock:(CCControlBlock)block forControlEvent:(CCControlEvent)controlEvent;

#endif

@end

@implementation CCControl
@synthesize dispatchTable           = dispatchTable_;
@synthesize dispatchBlockTable      = dispatchBlockTable_;
@synthesize defaultTouchPriority    = defaultTouchPriority_;
@synthesize state                   = state_;
@synthesize enabled                 = enabled_;
@synthesize selected                = selected_;
@synthesize highlighted             = highlighted_;
@synthesize opacity                 = opacity_;
@synthesize color                   = color_;
@synthesize opacityModifyRGB        = opacityModifyRGB_;

- (void)dealloc
{
    [dispatchBlockTable_    release];
    [dispatchTable_         release];
    
    [super                  dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		// Enabled the touch event
        self.isTouchEnabled         = YES;
#elif __MAC_OS_X_VERSION_MAX_ALLOWED
        // Enabled the mouse event
		self.mouseEnabled         = YES;
#endif
        
        // Initialise instance variables
        state_                      = CCControlStateNormal;
        
        self.enabled                = YES;
        self.selected               = NO;
        self.highlighted            = NO;
        
        // Set the touch dispatcher priority by default to 1
        self.defaultTouchPriority   = 1;
        
        // Initialise the tables
        dispatchTable_              = [[NSMutableDictionary alloc] initWithCapacity:1];
        dispatchBlockTable_         = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

- (void)onEnter
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    CCTouchDispatcher * dispatcher  = [CCDirector sharedDirector].touchDispatcher;
	[dispatcher addTargetedDelegate:self priority:defaultTouchPriority_ swallowsTouches:YES];
#endif
	[super onEnter];
}

- (void)onExit
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    CCTouchDispatcher * dispatcher  = [CCDirector sharedDirector].touchDispatcher;
	[dispatcher removeDelegate:self];
#endif
    
	[super onExit];
}

#if __MAC_OS_X_VERSION_MAX_ALLOWED

- (NSInteger)mouseDelegatePriority
{
	return defaultTouchPriority_;
}

#endif

#pragma mark Properties

- (void)setColor:(ccColor3B)color
{
    color_ = color;
    
    for (CCNode<CCRGBAProtocol> *child in self.children)
    {
        [child setColor:color];
    }
}

- (void)setOpacity:(GLubyte)opacity
{
    opacity_ = opacity;
    
    for (CCNode<CCRGBAProtocol> *child in self.children)
    {
        [child setOpacity:opacity];
    }
}

- (void)setOpacityModifyRGB:(BOOL)opacityModifyRGB
{
    opacityModifyRGB_ = opacityModifyRGB;
    
    for (CCNode<CCRGBAProtocol> *child in self.children)
    {
        [child setOpacityModifyRGB:opacityModifyRGB];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    enabled_        = enabled;
    
    if(enabled_) {
        state_ = CCControlStateNormal;
    } else {
        state_ = CCControlStateDisabled;
    }
    
    [self needsLayout];
}

- (void)setSelected:(BOOL)selected
{
    selected_       = selected;
    
    [self needsLayout];
}

- (void)setHighlighted:(BOOL)highlighted
{
    highlighted_    = highlighted;
    
    [self needsLayout];
}

- (BOOL) hasVisibleParents
{
    for( CCNode *c = self.parent; c != nil; c = c.parent )
    {
		if( !c.visible ) return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark CCControl Public Methods

- (void)sendActionsForControlEvents:(CCControlEvent)controlEvents
{
    // For each control events
    for (int i = 0; i < kControlEventTotalNumber; i++)
    {
        // If the given controlEvents bitmask contains the curent event
        if ((controlEvents & (1 << i)))
        {
            // Call invocations
            NSArray *invocationList = [self dispatchListforControlEvent:(1 << i)];
            for (NSInvocation *invocation in invocationList)
            {
                [invocation invoke];
            }
            
            // Call blocks
            CCControlBlock block = [dispatchBlockTable_ objectForKey:[NSNumber numberWithUnsignedInteger:(1 << i)]];
            if (block)
            {
                block (self, (1 << i));
            }
        }
    }
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(CCControlEvent)controlEvents
{
    // For each control events
    for (int i = 0; i < kControlEventTotalNumber; i++)
    {
        // If the given controlEvents bitmask contains the curent event
        if ((controlEvents & (1 << i)))
        {
            [self addTarget:target action:action forControlEvent:(1 << i)];
        }
    }
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(CCControlEvent)controlEvents
{
    // For each control events
    for (int i = 0; i < kControlEventTotalNumber; i++)
    {
        // If the given controlEvents bitmask contains the curent event
        if ((controlEvents & (1 << i)))
        {
            [self removeTarget:target action:action forControlEvent:(1 << i)];
        }
    }
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (CGPoint)touchLocation:(UITouch *)touch
{
    CGPoint touchLocation   = [touch locationInView:[touch view]];                      // Get the touch position
    touchLocation           = [[CCDirector sharedDirector] convertToGL:touchLocation];  // Convert the position to GL space
    touchLocation           = [self convertToNodeSpace:touchLocation];                  // Convert to the node space of this class
    
    return touchLocation;
}

- (BOOL)isTouchInside:(UITouch *)touch
{
    CGPoint touchLocation   = [touch locationInView:[touch view]];                      // Get the touch position
    touchLocation           = [[CCDirector sharedDirector] convertToGL:touchLocation];  // Convert the position to GL space
    touchLocation           = [[self parent] convertToNodeSpace:touchLocation];         // Convert to the node space of this class

    return CGRectContainsPoint([self boundingBox], touchLocation);
}

#elif __MAC_OS_X_VERSION_MAX_ALLOWED

- (CGPoint)eventLocation:(NSEvent *)event
{
    CGPoint eventLocation   = [[CCDirector sharedDirector] convertEventToGL:event];
    eventLocation           = [self convertToNodeSpace:eventLocation];
    
    return eventLocation;
}

- (BOOL)isMouseInside:(NSEvent *)event
{
    CGPoint eventLocation   = [[CCDirector sharedDirector] convertEventToGL:event];
    eventLocation           = [[self parent] convertToNodeSpace:eventLocation];

    return CGRectContainsPoint([self boundingBox], eventLocation);
}

#endif

- (void)needsLayout
{
}

#pragma mark CCControl Private Methods

- (void)addTarget:(id)target action:(SEL)action forControlEvent:(CCControlEvent)controlEvent
{
    // Create the invocation object
    NSInvocation *invocation = [self invocationWithTarget:target action:action forControlEvent:controlEvent];
    
    // Add the invocation into the dispatch list for the given control event
    NSMutableArray *eventInvocationList = [self dispatchListforControlEvent:controlEvent];
    [eventInvocationList addObject:invocation];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvent:(CCControlEvent)controlEvent
{
    // Retrieve all invocations for the given control event
    NSMutableArray *eventInvocationList = [self dispatchListforControlEvent:controlEvent];

    NSPredicate *predicate = 
    [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings)
     {
         NSInvocation *evaluatedObject = object;
         
         if ((target == nil && action == NULL)
             || (target == nil && [evaluatedObject selector] == action)
             || (action == NULL && [evaluatedObject target] == target)
             || ([evaluatedObject target] == target && [evaluatedObject selector] == action))
         {
             return YES;
         } 

         return NO;
     }];
    
    // Define the invocation to remove for the given control event
    NSArray *removeObjectList = [eventInvocationList filteredArrayUsingPredicate:predicate];
    
    // Remove the corresponding invocation objects
    [eventInvocationList removeObjectsInArray:removeObjectList];
}

- (NSInvocation *)invocationWithTarget:(id)target action:(SEL)action forControlEvent:(CCControlEvent)controlEvent
{
    NSAssert(target, @"The target cannot be nil");
    NSAssert(action != NULL, @"The action cannot be NULL");
    
    // Create the method signature for the invocation
    NSMethodSignature *sig = [target methodSignatureForSelector:action];
    NSAssert(sig, @"The given target does not implement the given action");
    
    // Create the invocation object
    // First and second corresponds respectively to target and action
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:target];
    [invocation setSelector:action];
    
    // If the selector accept the sender as third argument
    if ([sig numberOfArguments] >= 3)
    {
        [invocation setArgument:&self atIndex:2];
    }
    
    // If the selector accept the CCControlEvent as fourth argument
    if ([sig numberOfArguments] >= 4)
    {
        [invocation setArgument:&controlEvent atIndex:3];
    }
    
    return invocation;
}

- (NSMutableArray *)dispatchListforControlEvent:(CCControlEvent)controlEvent
{
    // Get the key for the given control event
    NSNumber *controlEventKey = [NSNumber numberWithUnsignedInteger:controlEvent];
    
    // Get the invocation list for the  dispatch table
    NSMutableArray *invocationList = [dispatchTable_ objectForKey:controlEventKey];
    
    // If the invocation list does not exist for the  dispatch table, we create it
    if (invocationList == nil)
    {
        invocationList = [NSMutableArray arrayWithCapacity:1];
        
        [dispatchTable_ setObject:invocationList forKey:controlEventKey];
    }
    
    return invocationList;
}


#pragma mark -
#pragma mark CCControl Public Blocks Methods

- (void)setBlock:(CCControlBlock)block forControlEvents:(CCControlEvent)controlEvents
{
    // For each control events
    for (int i = 0; i < kControlEventTotalNumber; i++)
    {
        // If the given controlEvents bitmask contains the curent event
        if ((controlEvents & (1 << i)))
        {
            [self setBlock:block forControlEvent:(1 << i)];
        }
    }
}

#pragma mark CCControl Private Blocks Methods

- (void)setBlock:(CCControlBlock)block forControlEvent:(CCControlEvent)controlEvent
{    
    // Get the key for the given control event
    NSNumber *controlEventKey = [NSNumber numberWithUnsignedInteger:controlEvent];
    
    if (block)
    {
        // Think to copy and release the block
        CCControlBlock currentBlock = [block copy];
        [dispatchBlockTable_ setObject:currentBlock forKey:controlEventKey];
        [currentBlock release];
    } else
    {
        [dispatchBlockTable_ removeObjectForKey:controlEventKey];
    }
}

@end
