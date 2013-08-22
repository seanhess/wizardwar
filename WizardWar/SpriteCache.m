//
//  SpriteCache.m
//  WizardWar
//
//  Created by Sean Hess on 8/14/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpriteCache.h"
#import "cocos2d.h"

@interface SpriteCache ()
@property (nonatomic) BOOL isCached;
@end

@implementation SpriteCache

+(SpriteCache*)shared {
    static SpriteCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SpriteCache alloc] init];
    });
    return instance;
}

- (void)cacheFramesAndAnimations {
    if (self.isCached) return;
    self.isCached = YES;
    
    NSLog(@"---- SpriteCache cacheFramesAndAnimations ----");
    
    // SPELLS
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spells-core.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"spells-extra.plist"];
    
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"explode-animation.plist"];
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"firewall-animation.plist"];
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"chicken-animation.plist"];
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"lightning-animation.plist"];
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"ogre-animation.plist"];
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"fireball-animation.plist"];
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"windblast-animation.plist"];
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"bubble-animation.plist"];
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"vine-animation.plist"];
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"icewall-animation.plist"];
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"earthwall-animation.plist"];
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"cthulhu-animation.plist"];    
    
    
    // WIZARDS
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard1.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard1-clothes.plist"];
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"wizard1-animations.plist"];
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"wizard1-animations-clothes.plist"];
}


@end
