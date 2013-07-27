//
// Scale9Sprite.h
//
// Public domain. Use in anyway you see fit. No waranties of any kind express or implied.
// Based off work of Steve Oldmeadow and Jose Antonio Andújar Clavell
//
// Modification added by Yannick Loriot
// Modification added by Viktor Lidholt
//

#import "cocos2d.h"

/**
 * A 9-slice sprite for cocos2d.
 */
@interface CCScale9Sprite : CCNode <CCRGBAProtocol>
{
@public
    CGSize              originalSize_;
    CGSize              preferedSize_;
    CGRect              capInsets_;
    
    float               insetLeft_;
    float               insetTop_;
    float               insetRight_;
    float               insetBottom_;
    
@protected
    CGRect              spriteRect;
    BOOL                spriteFrameRotated_;
    CGRect              capInsetsInternal_;
    BOOL                positionsAreDirty_;
    
    CCSpriteBatchNode   *scale9Image;
    CCSprite            *topLeft;
    CCSprite            *top;
    CCSprite            *topRight;
    CCSprite            *left;
    CCSprite            *centre;
    CCSprite            *right;
    CCSprite            *bottomLeft;
    CCSprite            *bottom;
    CCSprite            *bottomRight;
    BOOL                spritesGenerated_;
    
    // texture RGBA
    GLubyte             opacity_;
    ccColor3B           color_;
    BOOL                opacityModifyRGB_;
}
/** Original sprite's size. */
@property (nonatomic, readonly) CGSize originalSize;
/** Prefered sprite's size. By default the prefered size is the original size. */
@property (nonatomic, assign) CGSize preferedSize;
/** 
 * The end-cap insets. 
 * On a non-resizeable sprite, this property is set to CGRectZero; the sprite 
 * does not use end caps and the entire sprite is subject to stretching. 
 */
@property(nonatomic, assign) CGRect capInsets;
/** Sets the left side inset */
@property(nonatomic, assign) float insetLeft;
/** Sets the top side inset */
@property(nonatomic, assign) float insetTop;
/** Sets the right side inset */
@property(nonatomic, assign) float insetRight;
/** Sets the bottom side inset */
@property(nonatomic, assign) float insetBottom;

/** Conforms to CocosNodeRGBA protocol. */
@property (nonatomic, readwrite) GLubyte opacity;
/** Conforms to CocosNodeRGBA protocol. */
@property (nonatomic, readwrite) ccColor3B color;
/** Conforms to CocosNodeRGBA protocol. */
@property (nonatomic, getter = doesOpacityModifyRGB) BOOL opacityModifyRGB;

#pragma mark Constructor - Initializers

/**
 * Initializes a 9-slice sprite with a texture file, a delimitation zone and
 * with the specified cap insets.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param file The name of the texture file.
 * @param rect The rectangle that describes the sub-part of the texture that
 * is the whole image. If the shape is the whole texture, set this to the 
 * texture's full rect.
 * @param capInsets The values to use for the cap insets.
 */
- (id)initWithFile:(NSString *)file rect:(CGRect)rect capInsets:(CGRect)capInsets;

/** 
 * Creates a 9-slice sprite with a texture file, a delimitation zone and
 * with the specified cap insets.
 *
 * @see initWithFile:rect:centerRegion:
 */
+ (id)spriteWithFile:(NSString *)file rect:(CGRect)rect capInsets:(CGRect)capInsets;

/**
 * Initializes a 9-slice sprite with a texture file and a delimitation zone. The
 * texture will be broken down into a 3×3 grid of equal blocks.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param file The name of the texture file.
 * @param rect The rectangle that describes the sub-part of the texture that
 * is the whole image. If the shape is the whole texture, set this to the 
 * texture's full rect.
 */
- (id)initWithFile:(NSString *)file rect:(CGRect)rect;

/** 
 * Creates a 9-slice sprite with a texture file and a delimitation zone. The
 * texture will be broken down into a 3×3 grid of equal blocks.
 *
 * @see initWithFile:rect:
 */
+ (id)spriteWithFile:(NSString *)file rect:(CGRect)rect;

/**
 * Initializes a 9-slice sprite with a texture file and with the specified cap
 * insets.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param file The name of the texture file.
 * @param capInsets The values to use for the cap insets.
 */
- (id)initWithFile:(NSString *)file capInsets:(CGRect)capInsets;

/** 
 * Creates a 9-slice sprite with a texture file. The whole texture will be
 * broken down into a 3×3 grid of equal blocks.
 *
 * @see initWithFile:capInsets:
 */
+ (id)spriteWithFile:(NSString *)file capInsets:(CGRect)capInsets;

/**
 * Initializes a 9-slice sprite with a texture file. The whole texture will be
 * broken down into a 3×3 grid of equal blocks.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param file The name of the texture file.
 */
- (id)initWithFile:(NSString *)file;

/** 
 * Creates a 9-slice sprite with a texture file. The whole texture will be
 * broken down into a 3×3 grid of equal blocks.
 *
 * @see initWithFile:
 */
+ (id)spriteWithFile:(NSString *)file;

/**
 * Initializes a 9-slice sprite with an sprite frame and with the specified 
 * cap insets.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param spriteFrame The sprite frame object.
 * @param capInsets The values to use for the cap insets.
 */
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame capInsets:(CGRect)capInsets;

/**
 * Creates a 9-slice sprite with an sprite frame and the centre of its zone.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @see initWithSpriteFrame:centerRegion:
 */
+ (id)spriteWithSpriteFrame:(CCSpriteFrame *)spriteFrame capInsets:(CGRect)capInsets;

/**
 * Initializes a 9-slice sprite with an sprite frame.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param spriteFrame The sprite frame object.
 */
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame;

/**
 * Creates a 9-slice sprite with an sprite frame.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @see initWithSpriteFrame:
 */
+ (id)spriteWithSpriteFrame:(CCSpriteFrame *)spriteFrame;

/**
 * Initializes a 9-slice sprite with an sprite frame name and with the specified 
 * cap insets.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param spriteFrameName The sprite frame name.
 * @param capInsets The values to use for the cap insets.
 */
- (id)initWithSpriteFrameName:(NSString *)spriteFrameName capInsets:(CGRect)capInsets;

/**
 * Creates a 9-slice sprite with an sprite frame name and the centre of its
 * zone.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @see initWithSpriteFrameName:centerRegion:
 */
+ (id)spriteWithSpriteFrameName:(NSString *)spriteFrameName capInsets:(CGRect)capInsets;

/**
 * Initializes a 9-slice sprite with an sprite frame name.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @param spriteFrameName The sprite frame name.
 */
- (id)initWithSpriteFrameName:(NSString *)spriteFrameName;

/**
 * Creates a 9-slice sprite with an sprite frame name.
 * Once the sprite is created, you can then call its "setContentSize:" method
 * to resize the sprite will all it's 9-slice goodness intract.
 * It respects the anchorPoint too.
 *
 * @see initWithSpriteFrameName:
 */
+ (id)spriteWithSpriteFrameName:(NSString *)spriteFrameName;

#pragma mark Public Methods

/**
 * Creates and returns a new sprite object with the specified cap insets.
 * You use this method to add cap insets to a sprite or to change the existing
 * cap insets of a sprite. In both cases, you get back a new image and the 
 * original sprite remains untouched.
 *
 * @param capInsets The values to use for the cap insets.
 */
- (CCScale9Sprite *)resizableSpriteWithCapInsets:(CGRect)capInsets;

/**
 * Sets the sprite frame used to display the 9-slice sprite.
 *
 * @param spriteFrame The new sprite frame.
 */
- (void) setSpriteFrame:(CCSpriteFrame*) spriteFrame;

@end
