//
//  SpriteCache.h
//  WizardWar
//
//  Created by Sean Hess on 8/14/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpriteCache : NSObject

+(SpriteCache*)shared;
-(void)cacheFramesAndAnimations;

@end
