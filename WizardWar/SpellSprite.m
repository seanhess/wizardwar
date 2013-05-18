//
//  SpellSprite.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellSprite.h"
#import "cocos2d.h"

@interface SpellSprite ()
@property (nonatomic, strong) Units * units;
@property (nonatomic, strong) CCSprite * skin;
@property (nonatomic, strong) CCSpriteBatchNode * sheet;
@property (nonatomic, strong) CCAction * action;
@end

@implementation SpellSprite


-(id)initWithSpell:(Spell*)spell units:(Units *)units {
    if ((self=[super init])) {
        self.spell = spell;
        self.units = units;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"fireball.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"fireball-animation.plist"];
        
        self.sheet = [CCSpriteBatchNode batchNodeWithFile:@"fireball.png"];
        [self addChild:self.sheet];
        
        CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"fireball"];
        CCAction * action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
        
        self.skin = [CCSprite spriteWithSpriteFrameName:@"fireball-1"];
        [self.skin runAction:action];
        [self addChild:self.skin];
        
        spell.delegate = self;
        
    }
    return self;
}

-(void)didUpdateForRender {
    [self render];
}

-(void)render {
    self.position = ccp([self.units toX:self.spell.position], self.units.zeroY);
}

@end
