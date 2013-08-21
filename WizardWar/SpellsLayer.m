//
//  SpellLayer.m
//  WizardWar
//
//  Created by Sean Hess on 8/14/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//


#import "SpellsLayer.h"
#import "cocos2d.h"
#import "SpriteCache.h"
#import "SpellCheeseCaptainPlanet.h"

@interface SpellsLayer ()
@property (nonatomic, strong) CCSpriteBatchNode * batchCore;
@property (nonatomic, strong) CCSpriteBatchNode * batchExtra;
@end

@implementation SpellsLayer

-(id)init {
    self = [super init];
    if (self) {
        [SpriteCache.shared cacheFramesAndAnimations];
//        self.batchCore = [CCSpriteBatchNode batchNodeWithFile:@"spells-core.pvr.ccz"];
//        self.batchExtra = [CCSpriteBatchNode batchNodeWithFile:@"spells-extra.pvr.ccz"];
//        
//        [self addChild:self.batchCore];
//        [self addChild:self.batchExtra];
    }
    return self;
}

-(void)update:(ccTime)delta {
    for (SpellSprite * sprite in self.allSpellSprites) {
        [sprite update:delta];
    }
}


-(void)addSpell:(SpellSprite*)sprite {
    // default to core
    [self addChild:sprite];
    
//    if ([sprite.spell isKindOfClass:[SpellFail class]] || [sprite.spell isKindOfClass:[SpellCheeseCaptainPlanet class]]) {
//        [self.batchExtra addChild:sprite];
//    } else {
//        [self.batchCore addChild:sprite];
//    }
}

-(id<NSFastEnumeration>)allSpellSprites {
    return self.children;
//    NSMutableArray * allsprites = [NSMutableArray array];
//    
//    for (SpellSprite * sprite in self.batchCore.children) {
//        [allsprites addObject:sprite];
//    }
//    
//    for (SpellSprite * sprite in self.batchExtra.children) {
//        [allsprites addObject:sprite];
//    }
//    
//    return allsprites;
}

@end
