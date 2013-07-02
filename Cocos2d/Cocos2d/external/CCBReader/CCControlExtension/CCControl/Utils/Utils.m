//
//  Utils.m
//  SketchShareMenu
//
//  Created by stewart hamilton-arrandale on 30/11/2011.
//  Copyright (c) 2011 creative wax limited. All rights reserved.
//

#import "Utils.h"

@implementation Utils


+ (CCSprite *)addSprite:(NSString *)spriteName toTarget:(CCNode *)target withPos:(CGPoint)pos andAnchor:(CGPoint)anchor
{
	CCSprite *sprite	= [CCSprite spriteWithSpriteFrameName:spriteName];
    
    // check the sprite exists
    BOOL responds		= [sprite respondsToSelector:@selector(setPosition:)];
    
    if (responds == NO)	return nil;
    
	sprite.anchorPoint	= anchor;
	sprite.position		= pos;
	[target addChild:sprite];
	
	return sprite;
}

@end
