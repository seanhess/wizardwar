//
//  SpellSprite.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellSprite.h"
#import "cocos2d.h"
#import "SpellFireball.h"
#import "SpellEarthwall.h"

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
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"earthwall.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"earthwall-animation.plist"];
        
        self.sheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png", self.sheetName]];
        [self addChild:self.sheet];
        
        self.skin = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@-1", self.sheetName]];
        if (spell.direction < 0) self.skin.flipX = YES;
        [self.skin runAction:self.spellAction];
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

-(NSString*)sheetName {
    if ([self.spell isType:[SpellEarthwall class]]) {
        return @"earthwall";
    }
    
    return @"fireball";
}

-(CCAction*)spellAction {
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:self.sheetName];
    animation.restoreOriginalFrame = NO;
    
    CCActionInterval * actionInterval = [CCAnimate actionWithAnimation:animation];
    CCAction * action = actionInterval;
    
    if ([self.spell isType:[SpellFireball class]]) {
        action = [CCRepeatForever actionWithAction:actionInterval];
    }
    
    return action;
}

@end
