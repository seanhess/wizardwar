/*
 * CCControlSwitch.m
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

#import "CCControlSwitch.h"

#pragma mark CCControlSwitchSprite - Interface 

@interface CCControlSwitchSprite : CCSprite
{
@public
    CGFloat                                 sliderXPosition_;
    CGFloat                                 onPosition_;
    CGFloat                                 offPosition_;
    
    CCTexture2D                             *maskTexture_;
    GLuint                                  textureLocation_;
    GLuint                                  maskLocation_;
    
    CCSprite                                *onSprite_;
    CCSprite                                *offSprite_;
    CCSprite                                *thumbSprite_;
    CCNode<CCLabelProtocol, CCRGBAProtocol> *onLabel_;
    CCNode<CCLabelProtocol, CCRGBAProtocol> *offLabel_;
}
/** Contains the position (in x-axis) of the slider inside the receiver. */
@property (nonatomic, assign) CGFloat                                   sliderXPosition;
@property (nonatomic, assign) CGFloat                                   onPosition;
@property (nonatomic, assign) CGFloat                                   offPosition;

@property (nonatomic, strong) CCTexture2D                               *maskTexture;
@property (nonatomic, assign) GLuint                                    textureLocation;
@property (nonatomic, assign) GLuint                                    maskLocation;

@property (nonatomic, strong) CCSprite                                  *onSprite;
@property (nonatomic, strong) CCSprite                                  *offSprite;
@property (nonatomic, strong) CCSprite                                  *thumbSprite;
@property (nonatomic, strong) CCNode<CCLabelProtocol, CCRGBAProtocol>   *onLabel;
@property (nonatomic, strong) CCNode<CCLabelProtocol, CCRGBAProtocol>   *offLabel;

#pragma mark Contructors Initializers

- (id)initWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite onLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)onLabel offLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)offLabel;

#pragma mark Public Methods

/** Updates the layout using the current state value. */
- (void)needsLayout;

@end

#pragma mark - CCControlSwitch Implementation

@interface CCControlSwitch ()
/** Sprite which represents the view. */
@property (nonatomic, strong) CCControlSwitchSprite *switchSprite;
@property (nonatomic, assign) CGFloat               initialTouchXPosition;
@property (nonatomic, getter = hasMoved) BOOL       moved;

@end

@implementation CCControlSwitch
@synthesize switchSprite            = switchSprite_;
@synthesize initialTouchXPosition   = initialTouchXPosition_;
@synthesize moved                   = moved_;
@synthesize on                      = on_;

- (void)dealloc
{
    [switchSprite_  release];
    
    [super          dealloc];
}

- (id)initWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite
{
    return [self initWithMaskSprite:maskSprite onSprite:onSprite offSprite:offSprite thumbSprite:thumbSprite onLabel:nil offLabel:nil];
}

+ (id)switchWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite
{
    return [[[self alloc] initWithMaskSprite:maskSprite onSprite:onSprite offSprite:offSprite thumbSprite:thumbSprite] autorelease];
}

- (id)initWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite onLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)onLabel offLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)offLabel
{
    if ((self = [super init]))
    {
        NSAssert(maskSprite,    @"Mask must not be nil.");
        NSAssert(onSprite,      @"onSprite must not be nil.");
        NSAssert(offSprite,     @"offSprite must not be nil.");
        NSAssert(thumbSprite,   @"thumbSprite must not be nil.");
        
        on_                         = YES;

        switchSprite_               = [[CCControlSwitchSprite alloc] initWithMaskSprite:maskSprite 
                                                                               onSprite:onSprite
                                                                              offSprite:offSprite 
                                                                            thumbSprite:thumbSprite 
                                                                                onLabel:onLabel 
                                                                               offLabel:offLabel];
        switchSprite_.position      = ccp (switchSprite_.contentSize.width / 2, switchSprite_.contentSize.height / 2);
        [self addChild:switchSprite_];
        
        self.ignoreAnchorPointForPosition  = NO;
        self.anchorPoint            = ccp (0.5f, 0.5f);
        self.contentSize            = [switchSprite_ contentSize];
    }
    return self;
}

+ (id)switchWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite onLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)onLabel offLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)offLabel
{
    return [[[self alloc] initWithMaskSprite:maskSprite onSprite:onSprite offSprite:offSprite thumbSprite:thumbSprite onLabel:onLabel offLabel:offLabel] autorelease];
}

#pragma mark Properties

- (void)setOn:(BOOL)isOn
{
    [self setOn:isOn animated:NO];
}

- (void)setOn:(BOOL)isOn animated:(BOOL)animated
{
    on_     = isOn;

    [switchSprite_ runAction:
     [CCActionTween actionWithDuration:0.2f 
                                   key:@"sliderXPosition" 
                                  from:switchSprite_.sliderXPosition
                                    to:(on_) ? switchSprite_.onPosition : switchSprite_.offPosition]];
    
    [self sendActionsForControlEvents:CCControlEventValueChanged];
}

- (void)setEnabled:(BOOL)enabled
{
    enabled_                            = enabled;

    switchSprite_.opacity               = (enabled) ? 255.0f : 128.0f;
}

#pragma mark CCTargetedTouch Delegate Methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

- (CGPoint)locationFromTouch:(UITouch *)touch
{
    CGPoint touchLocation   = [touch locationInView:[touch view]];                      // Get the touch position
    touchLocation           = [[CCDirector sharedDirector] convertToGL:touchLocation];  // Convert the position to GL space
    touchLocation           = [self convertToNodeSpace:touchLocation];                  // Convert to the node space of this class
    
    return touchLocation;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self isTouchInside:touch]
        || ![self isEnabled])
    {
        return NO;
    }
    
    moved_                          = NO;
    
    CGPoint location                = [self locationFromTouch:touch];
    
    initialTouchXPosition_          = location.x - switchSprite_.sliderXPosition;
    
    switchSprite_.thumbSprite.color = ccGRAY;
    [switchSprite_ needsLayout];
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location    = [self locationFromTouch:touch];
    location            = ccp (location.x - initialTouchXPosition_, 0);
    
    moved_              = YES;
    
    [switchSprite_ setSliderXPosition:location.x];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location   = [self locationFromTouch:touch];
    
    switchSprite_.thumbSprite.color  = ccWHITE;
    
    if ([self hasMoved])
    {
        [self setOn:!(location.x < switchSprite_.contentSize.width / 2) animated:YES];
    } else
    {
        [self setOn:![self isOn] animated:YES];
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location   = [self locationFromTouch:touch];
    
    switchSprite_.thumbSprite.color  = ccWHITE;
    
    if ([self hasMoved])
    {
        [self setOn:!(location.x < switchSprite_.contentSize.width / 2) animated:YES];
    } else
    {
        [self setOn:![self isOn] animated:YES];
    }
}

#endif

@end

#pragma mark - CCControlSwitchSprite Implementation

@implementation CCControlSwitchSprite
@synthesize maskTexture         = maskTexture_;
@synthesize textureLocation     = textureLocation_;
@synthesize maskLocation        = maskLocation_;
@synthesize onSprite            = onSprite_;
@synthesize offSprite           = offSprite_;
@synthesize thumbSprite         = thumbSprite_;
@synthesize onLabel             = onLabel_;
@synthesize offLabel            = offLabel_;
@synthesize sliderXPosition     = sliderXPosition_;
@synthesize onPosition          = onPosition_;
@synthesize offPosition         = offPosition_;

- (void)dealloc
{
    [onSprite_      release];
    [offSprite_     release];
    [thumbSprite_   release];
    [onLabel_       release];
    [offLabel_      release];
    [maskTexture_   release];
    
    [super          dealloc];
}

- (id)init
{
    NSAssert(NO, @"Use 'initWithMaskFile:onSprite:offSprite:thumbSprite:onLabel:onLabeloffLabel:' initialazer instead of 'init'");
    return nil;
}

- (id)initWithMaskSprite:(CCSprite *)maskSprite onSprite:(CCSprite *)onSprite offSprite:(CCSprite *)offSprite thumbSprite:(CCSprite *)thumbSprite onLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)onLabel offLabel:(CCNode<CCLabelProtocol, CCRGBAProtocol> *)offLabel
{
    if ((self = [super initWithTexture:[maskSprite texture]]))
    {
        // Sets the default values
        onPosition_             = 0;
        offPosition_            = -onSprite.contentSize.width + thumbSprite.contentSize.width / 2;
        sliderXPosition_        = onPosition_; 
        
        self.onSprite           = onSprite;
        self.offSprite          = offSprite;
        self.thumbSprite        = thumbSprite;
        self.onLabel            = onLabel;
        self.offLabel           = offLabel;
        
        [self addChild:thumbSprite_];
        
        // Set up the mask with the Mask shader
        self.maskTexture        = [maskSprite texture];
        self.shaderProgram      = [[CCGLProgram alloc] initWithVertexShaderFilename:@"PositionTextureColor.vsh"
                                                             fragmentShaderFilename:@"CCControlSwitchMask.fsh"];
        CHECK_GL_ERROR_DEBUG();
        
        [_shaderProgram addAttribute:kCCAttributeNamePosition   index:kCCVertexAttrib_Position];
        [_shaderProgram addAttribute:kCCAttributeNameColor      index:kCCVertexAttrib_Color];
        [_shaderProgram addAttribute:kCCAttributeNameTexCoord   index:kCCVertexAttrib_TexCoords];
        CHECK_GL_ERROR_DEBUG();
        
        [_shaderProgram link];
        CHECK_GL_ERROR_DEBUG();
        
        [_shaderProgram updateUniforms];
        CHECK_GL_ERROR_DEBUG();                
        
        self.textureLocation    = glGetUniformLocation( _shaderProgram.program, "u_texture");
        self.maskLocation       = glGetUniformLocation( _shaderProgram.program, "u_mask");
        CHECK_GL_ERROR_DEBUG();
        
        self.contentSize        = [maskTexture_ contentSize];
        
        [self needsLayout];
    }
    return self;
}

- (void)draw
{
    CC_NODE_DRAW_SETUP();
    
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);
    ccGLBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [_shaderProgram setUniformsForBuiltins];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture( GL_TEXTURE_2D, [_texture name] );
    glUniform1i(textureLocation_, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture( GL_TEXTURE_2D, [maskTexture_ name] );
    glUniform1i(maskLocation_, 1);
    
#define kQuadSize sizeof(_quad.bl)
    long offset = (long)&_quad;
    
    // vertex
    NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
    glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
    
    // texCoods
    diff = offsetof( ccV3F_C4B_T2F, texCoords);
    glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
    
    // color
    diff = offsetof( ccV3F_C4B_T2F, colors);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);    
    glActiveTexture(GL_TEXTURE0);
}

- (void)needsLayout
{
    onSprite_.position      = ccp(onSprite_.contentSize.width / 2 + sliderXPosition_,
                                                            onSprite_.contentSize.height / 2);
    offSprite_.position     = ccp(onSprite_.contentSize.width + offSprite_.contentSize.width / 2 + sliderXPosition_, 
                                                            offSprite_.contentSize.height / 2);
    thumbSprite_.position   = ccp(onSprite_.contentSize.width + sliderXPosition_,
                                                            maskTexture_.contentSize.height / 2);
    
    if (onLabel_)
    {
        onLabel_.position   = ccp(onSprite_.position.x - thumbSprite_.contentSize.width / 6,
                                  onSprite_.contentSize.height / 2);
    }
    if (offLabel_)
    {
        offLabel_.position  = ccp(offSprite_.position.x + thumbSprite_.contentSize.width / 6,
                                  offSprite_.contentSize.height / 2);
    }
    
    CCRenderTexture *rt     = [CCRenderTexture renderTextureWithWidth:maskTexture_.contentSize.width 
                                                               height:maskTexture_.contentSize.height];
    
    [rt                 begin];
    [self.onSprite      visit];        
    [self.offSprite     visit]; 
    
    if (onLabel_)
    {
        [onLabel_       visit];
    }
    if (offLabel_)
    {
        [offLabel_      visit];
    }
    
    [rt                 end];

    self.texture            = rt.sprite.texture;
    self.flipY              = YES;
}

- (void)setSliderXPosition:(CGFloat)sliderXPosition
{
    if (sliderXPosition <= offPosition_)
    {
        // Off
        sliderXPosition = offPosition_;
    } else if (sliderXPosition >= onPosition_)
    {
        // On
        sliderXPosition = onPosition_;
    }
    
    sliderXPosition_    = sliderXPosition;
    
    [self needsLayout];
}

- (CGFloat)onSideWidth
{
    return onSprite_.contentSize.width;
}

- (CGFloat)offSideWidth
{
    return offSprite_.contentSize.height;
}

@end
