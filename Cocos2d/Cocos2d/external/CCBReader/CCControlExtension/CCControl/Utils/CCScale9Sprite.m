//
// Scale9Sprite.m
//
// Creates a 9-slice sprite.
//

#import "CCScale9Sprite.h"

enum positions
{
    pCentre = 0,
    pTop,
    pLeft,
    pRight,
    pBottom,
    pTopRight,
    pTopLeft,
    pBottomRight,
    pBottomLeft
};

@interface CCScale9Sprite ()

- (id)initWithBatchNode:(CCSpriteBatchNode *)batchnode rect:(CGRect)rect capInsets:(CGRect)capInsets;
- (void)updateWithBatchNode:(CCSpriteBatchNode*)batchnode rect:(CGRect)rect rotated:(BOOL)rotated capInsets:(CGRect)capInsets;
- (void)updatePosition;

@end

@implementation CCScale9Sprite
@synthesize originalSize        = originalSize_;
@synthesize capInsets           = capInsets_;
@synthesize opacity             = opacity_;
@synthesize color               = color_;
@synthesize opacityModifyRGB    = opacityModifyRGB_;
@synthesize insetTop            = insetTop_;
@synthesize insetLeft           = insetLeft_;
@synthesize insetBottom         = insetBottom_;
@synthesize insetRight          = insetRight_;
@synthesize preferedSize        = preferedSize_;

- (void)dealloc
{
    [topLeft        release];
    [top            release];
    [topRight       release];
    [left           release];
    [centre         release];
    [right          release];
    [bottomLeft     release];
    [bottom         release];
    [bottomRight    release];
    [scale9Image    release];
    
    [super          dealloc];
}

#pragma mark Constructor - Initializers

- (id)initWithBatchNode:(CCSpriteBatchNode *)batchnode rect:(CGRect)rect rotated:(BOOL)rotated capInsets:(CGRect)capInsets
{
    if ((self = [super init]))
    {
        if (batchnode)
        {
            [self updateWithBatchNode:batchnode rect:rect rotated:rotated capInsets:capInsets];
            _anchorPoint        = ccp(0.5f, 0.5f);
        }
        positionsAreDirty_ = YES;
    }
    return self;
}

- (id)initWithBatchNode:(CCSpriteBatchNode *)batchnode rect:(CGRect)rect capInsets:(CGRect)capInsets
{
    return [self initWithBatchNode:batchnode rect:rect rotated:NO capInsets:capInsets];
}

- (id)initWithFile:(NSString *)file rect:(CGRect)rect capInsets:(CGRect)capInsets
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    CCSpriteBatchNode *batchnode = [CCSpriteBatchNode batchNodeWithFile:file capacity:9];
    
    return [self initWithBatchNode:batchnode rect:rect capInsets:capInsets];
}

+ (id)spriteWithFile:(NSString *)file rect:(CGRect)rect capInsets:(CGRect)capInsets
{
    return [[[self alloc] initWithFile:file rect:rect capInsets:capInsets] autorelease];
}

- (id)initWithFile:(NSString *)file rect:(CGRect)rect
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    return [self initWithFile:file rect:rect capInsets:CGRectZero];
}

+ (id)spriteWithFile:(NSString *)file rect:(CGRect)rect
{
    return [[[self alloc] initWithFile:file rect:rect] autorelease];
}

- (id)initWithFile:(NSString *)file capInsets:(CGRect)capInsets
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    return [self initWithFile:file rect:CGRectZero capInsets:capInsets];
}

+ (id)spriteWithFile:(NSString *)file capInsets:(CGRect)capInsets
{
    return [[[self alloc] initWithFile:file capInsets:capInsets] autorelease];
}

- (id)initWithFile:(NSString *)file
{
    NSAssert(file != nil, @"Invalid file for sprite");
    
    return [self initWithFile:file rect:CGRectZero];
}

+ (id)spriteWithFile:(NSString *)file
{
    return [[[self alloc] initWithFile:file] autorelease];
}

- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame capInsets:(CGRect)capInsets
{
    NSAssert(spriteFrame != nil, @"Sprite frame must be not nil");
    
    CCSpriteBatchNode *batchnode = [CCSpriteBatchNode batchNodeWithTexture:spriteFrame.texture capacity:9];
    
    return [self initWithBatchNode:batchnode rect:spriteFrame.rect rotated:spriteFrame.rotated capInsets:capInsets];
}

+ (id)spriteWithSpriteFrame:(CCSpriteFrame *)spriteFrame capInsets:(CGRect)capInsets
{
    return [[[self alloc] initWithSpriteFrame:spriteFrame capInsets:capInsets] autorelease];
}

- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame
{
    NSAssert(spriteFrame != nil, @"Invalid spriteFrame for sprite");
    
    return [self initWithSpriteFrame:spriteFrame capInsets:CGRectZero];
}

+ (id)spriteWithSpriteFrame:(CCSpriteFrame *)spriteFrame
{
    return [[[self alloc] initWithSpriteFrame:spriteFrame] autorelease];
}

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName capInsets:(CGRect)capInsets
{
    NSAssert(spriteFrameName != nil, @"Invalid spriteFrameName for sprite");
    
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
    
    return [self initWithSpriteFrame:frame capInsets:capInsets];
}

+ (id)spriteWithSpriteFrameName:(NSString *)spriteFrameName capInsets:(CGRect)capInsets
{
    return [[[self alloc] initWithSpriteFrameName:spriteFrameName capInsets:capInsets] autorelease];
}

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName
{
    NSAssert(spriteFrameName != nil, @"Invalid spriteFrameName for sprite");
    
    return [self initWithSpriteFrameName:spriteFrameName capInsets:CGRectZero];
}

+ (id)spriteWithSpriteFrameName:(NSString *)spriteFrameName
{
    return [[[self alloc] initWithSpriteFrameName:spriteFrameName] autorelease];
}

- (id)init
{
    return [self initWithBatchNode:NULL rect:CGRectZero capInsets:CGRectZero];
}

- (void) updateWithBatchNode:(CCSpriteBatchNode*)batchnode rect:(CGRect)rect rotated:(BOOL)rotated capInsets:(CGRect)capInsets
{
    GLubyte opacity = opacity_;
    ccColor3B color = color_;
    
    // Release old sprites
    [self removeAllChildrenWithCleanup:YES];
    
    [centre         release];
    [top            release];
    [topLeft        release];
    [topRight       release];
    [left           release];
    [right          release];
    [bottomLeft     release];
    [bottom         release];
    [bottomRight    release];
    
    if (scale9Image != batchnode)
    {
        [scale9Image release];
        scale9Image = [batchnode retain];
    }
    
    [scale9Image removeAllChildrenWithCleanup:YES];
    
    capInsets_          = capInsets;
    spriteFrameRotated_ = rotated;
    
    // If there is no given rect
    if (CGRectEqualToRect(rect, CGRectZero))
    {
        // Get the texture size as original
        CGSize textureSize  = [[[scale9Image textureAtlas] texture] contentSize];
        
        rect                = CGRectMake(0, 0, textureSize.width, textureSize.height);
    }
    
    // Set the given rect's size as original size
    spriteRect          = rect;
    originalSize_       = rect.size;
    preferedSize_       = originalSize_;
    capInsetsInternal_  = capInsets;
    
    // Get the image edges
    float l = rect.origin.x;
    float t = rect.origin.y;
    float h = rect.size.height;
    float w = rect.size.width;
    
    // If there is no specified center region
    if (CGRectEqualToRect(capInsetsInternal_, CGRectZero))
    {
        // Apply the 3x3 grid format
        if (rotated)
        {
            capInsetsInternal_ = CGRectMake(l+h/3, t+w/3, w/3, h/3);
        }
        else
        {
            capInsetsInternal_  = CGRectMake(l+w/3, t+h/3, w/3, h/3);
        }
    }
    
    //
    // Set up the image
    //
    
    
    if (rotated)
    {
        // Sprite frame is rotated
        
        // Centre
        centre      = [[CCSprite alloc] initWithTexture:scale9Image.texture rect:capInsetsInternal_ rotated:YES];
        [scale9Image addChild:centre z:0 tag:pCentre];
        
        // Bottom
        bottom         = [[CCSprite alloc]
                       initWithTexture:scale9Image.texture
                       rect:CGRectMake(l,
                                       capInsetsInternal_.origin.y,
                                       capInsetsInternal_.size.width,
                                       capInsetsInternal_.origin.x - l)
                       rotated:rotated
                       ];
        [scale9Image addChild:bottom z:1 tag:pBottom];
        
        // Top
        top      = [[CCSprite alloc]
                       initWithTexture:scale9Image.texture
                       rect:CGRectMake(capInsetsInternal_.origin.x + capInsetsInternal_.size.height,
                                       capInsetsInternal_.origin.y,
                                       capInsetsInternal_.size.width,
                                       h - capInsetsInternal_.size.height - (capInsetsInternal_.origin.x - l))
                       rotated:rotated
                       ];
        [scale9Image addChild:top z:1 tag:pTop];
        
        // Right
        right        = [[CCSprite alloc]
                       initWithTexture:scale9Image.texture
                       rect:CGRectMake(capInsetsInternal_.origin.x,
                                       capInsetsInternal_.origin.y+capInsetsInternal_.size.width,
                                       w - (capInsetsInternal_.origin.y-t)-capInsetsInternal_.size.width,
                                       capInsetsInternal_.size.height)
                       rotated:rotated
                       ];
        [scale9Image addChild:right z:1 tag:pRight];
        
        // Left
        left       = [[CCSprite alloc]
                       initWithTexture:scale9Image.texture
                       rect:CGRectMake(capInsetsInternal_.origin.x,
                                       t,
                                       capInsetsInternal_.origin.y - t,
                                       capInsetsInternal_.size.height)
                       rotated:rotated
                       ];
        [scale9Image addChild:left z:1 tag:pLeft];
        
        // Top right
        topRight     = [[CCSprite alloc]
                       initWithTexture:scale9Image.texture
                       rect:CGRectMake(capInsetsInternal_.origin.x + capInsetsInternal_.size.height,
                                       capInsetsInternal_.origin.y + capInsetsInternal_.size.width,
                                       w - (capInsetsInternal_.origin.y-t)-capInsetsInternal_.size.width,
                                       h - capInsetsInternal_.size.height - (capInsetsInternal_.origin.x - l))
                       rotated:rotated
                       ];
        [scale9Image addChild:topRight z:2 tag:pTopRight];
        
        // Top left
        topLeft    = [[CCSprite alloc]
                       initWithTexture:scale9Image.texture
                       rect:CGRectMake(capInsetsInternal_.origin.x + capInsetsInternal_.size.height,
                                       t,
                                       capInsetsInternal_.origin.y - t,
                                       h - capInsetsInternal_.size.height - (capInsetsInternal_.origin.x - l))
                       rotated:rotated
                       ];
        [scale9Image addChild:topLeft z:2 tag:pTopLeft];
        
        // Bottom right
        bottomRight  = [[CCSprite alloc]
                       initWithTexture:scale9Image.texture
                       rect:CGRectMake(l,
                                       capInsetsInternal_.origin.y + capInsetsInternal_.size.width,
                                       w - (capInsetsInternal_.origin.y-t)-capInsetsInternal_.size.width,
                                       capInsetsInternal_.origin.x - l)
                       rotated:rotated
                       ];
        [scale9Image addChild:bottomRight z:2 tag:pBottomRight];
        
        // Bottom left
        bottomLeft     = [[CCSprite alloc]
                           initWithTexture:scale9Image.texture
                           rect:CGRectMake(l,
                                           t,
                                           capInsetsInternal_.origin.y - t,
                                           capInsetsInternal_.origin.x - l)
                           rotated:rotated
                           ];
        [scale9Image addChild:bottomLeft z:2 tag:pBottomLeft];
    }
    else
    {
        // Sprite frame is not rotated
        
        // Centre
        centre      = [[CCSprite alloc] initWithTexture:scale9Image.texture rect:capInsetsInternal_ rotated:rotated];
        [scale9Image addChild:centre z:0 tag:pCentre];
        
        // Top
        top         = [[CCSprite alloc]
                       initWithTexture:scale9Image.texture
                       rect:CGRectMake(capInsetsInternal_.origin.x,
                                       t,
                                       capInsetsInternal_.size.width,
                                       capInsetsInternal_.origin.y - t)
                       rotated:rotated
                       ];
        [scale9Image addChild:top z:1 tag:pTop];
        
        // Bottom
        bottom      = [[CCSprite alloc]
                       initWithTexture:scale9Image.texture
                       rect:CGRectMake(capInsetsInternal_.origin.x,
                                       capInsetsInternal_.origin.y + capInsetsInternal_.size.height,
                                       capInsetsInternal_.size.width,
                                       h - (capInsetsInternal_.origin.y - t + capInsetsInternal_.size.height))
                       rotated:rotated
                       ];
        [scale9Image addChild:bottom z:1 tag:pBottom];
        
        // Left
        left        = [[CCSprite alloc]
                       initWithTexture:scale9Image.texture
                       rect:CGRectMake(l,
                                       capInsetsInternal_.origin.y,
                                       capInsetsInternal_.origin.x - l,
                                       capInsetsInternal_.size.height)
                       rotated:rotated
                       ];
        [scale9Image addChild:left z:1 tag:pLeft];
        
        // Right
        right       = [[CCSprite alloc]
                       initWithTexture:scale9Image.texture
                       rect:CGRectMake(capInsetsInternal_.origin.x + capInsetsInternal_.size.width,
                                       capInsetsInternal_.origin.y,
                                       w - (capInsetsInternal_.origin.x - l + capInsetsInternal_.size.width),
                                       capInsetsInternal_.size.height)
                       rotated:rotated
                       ];
        [scale9Image addChild:right z:1 tag:pRight];
        
        // Top left
        topLeft     = [[CCSprite alloc]
                       initWithTexture:scale9Image.texture
                       rect:CGRectMake(l,
                                       t,
                                       capInsetsInternal_.origin.x - l,
                                       capInsetsInternal_.origin.y - t)
                       rotated:rotated
                       ];
        [scale9Image addChild:topLeft z:2 tag:pTopLeft];
        
        // Top right
        topRight    = [[CCSprite alloc]
                       initWithTexture:scale9Image.texture
                       rect:CGRectMake(capInsetsInternal_.origin.x + capInsetsInternal_.size.width,
                                       t,
                                       w - (capInsetsInternal_.origin.x - l + capInsetsInternal_.size.width),
                                       capInsetsInternal_.origin.y - t)
                       rotated:rotated
                       ];
        [scale9Image addChild:topRight z:2 tag:pTopRight];
        
        // Bottom left
        bottomLeft  = [[CCSprite alloc]
                       initWithTexture:scale9Image.texture
                       rect:CGRectMake(l,
                                       capInsetsInternal_.origin.y + capInsetsInternal_.size.height,
                                       capInsetsInternal_.origin.x - l,
                                       h - (capInsetsInternal_.origin.y - t + capInsetsInternal_.size.height))
                       rotated:rotated
                       ];
        [scale9Image addChild:bottomLeft z:2 tag:pBottomLeft];
        
        // Bottom right
        bottomRight     = [[CCSprite alloc]
                           initWithTexture:scale9Image.texture
                           rect:CGRectMake(capInsetsInternal_.origin.x + capInsetsInternal_.size.width,
                                           capInsetsInternal_.origin.y + capInsetsInternal_.size.height,
                                           w - (capInsetsInternal_.origin.x - l + capInsetsInternal_.size.width),
                                           h - (capInsetsInternal_.origin.y - t + capInsetsInternal_.size.height))
                           rotated:rotated
                           ];
        [scale9Image addChild:bottomRight z:2 tag:pBottomRight];
    }
    
    [self setContentSize:rect.size];
    [self addChild:scale9Image];
    
    if (spritesGenerated_)
    {
        // Restore color and opacity
        self.opacity = opacity;
        self.color = color;
    }
    spritesGenerated_ = YES;
}

#pragma mark Properties

- (void)setContentSize:(CGSize)size
{
    super.contentSize   = size;
    
    positionsAreDirty_  = YES;
}

- (void)updatePosition
{
    CGSize size             = _contentSize;
    
    float sizableWidth      = size.width - topLeft.contentSize.width - topRight.contentSize.width;
    float sizableHeight     = size.height - topLeft.contentSize.height - bottomRight.contentSize.height;
    
    float horizontalScale   = sizableWidth/centre.contentSize.width;
    float verticalScale     = sizableHeight/centre.contentSize.height;
    
    centre.scaleX           = horizontalScale;
    centre.scaleY           = verticalScale;
    
    float rescaledWidth     = centre.contentSize.width * horizontalScale;
    float rescaledHeight    = centre.contentSize.height * verticalScale;
    
    float leftWidth         = bottomLeft.contentSize.width;
    float bottomHeight      = bottomLeft.contentSize.height;
    
    // Set anchor points
    bottomLeft.anchorPoint  = ccp(0,0);
    bottomRight.anchorPoint = ccp(0,0);
    topLeft.anchorPoint     = ccp(0,0);
    topRight.anchorPoint    = ccp(0,0);
    left.anchorPoint        = ccp(0,0);
    right.anchorPoint       = ccp(0,0);
    top.anchorPoint         = ccp(0,0);
    bottom.anchorPoint      = ccp(0,0);
    centre.anchorPoint      = ccp(0,0);
    
    // Position corners
    bottomLeft.position     = ccp(0,0);
    bottomRight.position    = ccp(leftWidth+rescaledWidth,0);
    topLeft.position        = ccp(0, bottomHeight+rescaledHeight);
    topRight.position       = ccp(leftWidth+rescaledWidth, bottomHeight+rescaledHeight);
    
    // Scale and position borders
    left.position           = ccp(0, bottomHeight);
    left.scaleY             = verticalScale;
    right.position          = ccp(leftWidth+rescaledWidth,bottomHeight);
    right.scaleY            = verticalScale;
    bottom.position         = ccp(leftWidth,0);
    bottom.scaleX           = horizontalScale;
    top.position            = ccp(leftWidth,bottomHeight+rescaledHeight);
    top.scaleX              = horizontalScale;
    
    // Position centre
    centre.position         = ccp(leftWidth, bottomHeight);
}

- (void)setPreferedSize:(CGSize)preferedSize
{
    self.contentSize        = preferedSize;
    preferedSize_           = preferedSize;
}

#pragma mark Properties

- (void)setColor:(ccColor3B)color
{
    color_      = color;
    
    for (CCNode<CCRGBAProtocol> *child in scale9Image.children)
    {
        [child setColor:color];
    }
}

- (void)setOpacity:(GLubyte)opacity
{
    opacity_    = opacity;
    
    for (CCNode<CCRGBAProtocol> *child in scale9Image.children)
    {
        [child setOpacity:opacity];
    }
}

- (void)setOpacityModifyRGB:(BOOL)boolean
{
    opacityModifyRGB_ = boolean;
    
    for (CCNode<CCRGBAProtocol> *child in scale9Image.children)
    {
        [child setOpacityModifyRGB:boolean];
    }
}

- (void)setSpriteFrame:(CCSpriteFrame *)spriteFrame
{
    CCSpriteBatchNode *batchnode = [CCSpriteBatchNode batchNodeWithTexture:spriteFrame.texture capacity:9];
    [self updateWithBatchNode:batchnode rect:spriteFrame.rect rotated:spriteFrame.rotated capInsets:CGRectZero];
    
    // Reset insets
    insetLeft_      = 0;
    insetTop_       = 0;
    insetRight_     = 0;
    insetBottom_    = 0;
}

- (void)setCapInsets:(CGRect)capInsets
{
    CGSize contentSize = _contentSize;
    [self updateWithBatchNode:scale9Image rect:spriteRect rotated:spriteFrameRotated_ capInsets:capInsets];
    [self setContentSize:contentSize];
}

- (void) updateCapInset_
{
    CGRect insets;
    if (insetLeft_ == 0 && insetTop_ == 0 && insetRight_ == 0 && insetBottom_ == 0)
    {
        insets = CGRectZero;
    }
    else
    {
        if (spriteFrameRotated_)
        {
            insets = CGRectMake(spriteRect.origin.x + insetBottom_,
                                spriteRect.origin.y + insetLeft_,
                                spriteRect.size.width-insetRight_-insetLeft_,
                                spriteRect.size.height-insetTop_-insetBottom_);
        }
        else
        {
            insets = CGRectMake(spriteRect.origin.x + insetLeft_,
                                spriteRect.origin.y + insetTop_,
                                spriteRect.size.width-insetLeft_-insetRight_,
                                spriteRect.size.height-insetTop_-insetBottom_);
        }
    }
    [self setCapInsets:insets];
}

- (void) setInsetLeft:(float)insetLeft
{
    insetLeft_ = insetLeft;
    [self updateCapInset_];
}

- (void) setInsetTop:(float)insetTop
{
    insetTop_ = insetTop;
    [self updateCapInset_];
}

- (void) setInsetRight:(float)insetRight
{
    insetRight_ = insetRight;
    [self updateCapInset_];
}

- (void) setInsetBottom:(float)insetBottom
{
    insetBottom_ = insetBottom;
    [self updateCapInset_];
}

#pragma mark -
#pragma mark CCScale9Sprite Public Methods

- (CCScale9Sprite *)resizableSpriteWithCapInsets:(CGRect)capInsets
{
    return [[[CCScale9Sprite alloc] initWithBatchNode:scale9Image rect:spriteRect capInsets:capInsets] autorelease];
}

#pragma mark -
#pragma mark Overridden

- (void)visit
{
    if (positionsAreDirty_)
    {
        [self updatePosition];
        
        positionsAreDirty_ = NO;
    }
    
    [super visit];
}

@end
