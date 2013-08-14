//
//  OLSprite.h
//  WizardWar
//
//  Created by Sean Hess on 8/14/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "CCSprite.h"

@class OLSprite;

@protocol OLSpriteFrameDelegate <NSObject>
-(void)sprite:(OLSprite*)sprite didChangeFrame:(CCSpriteFrame*)frame;
@end

@interface OLSprite : CCSprite
@property (nonatomic, weak) id<OLSpriteFrameDelegate>delegate;

@end
