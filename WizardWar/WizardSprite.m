//
//  WizardSprite.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "WizardSprite.h"
#import "cocos2d.h"
#import "CCLabelTTF.h"
#import <ReactiveCocoa.h>
#import "SpellInvisibility.h"
#import "EffectInvisible.h"
#import "EffectHelmet.h"
#import "EffectHeal.h"
#import "EffectSleep.h"

#define WIZARD_PADDING 20
#define PIXELS_HIGH_PER_ALTITUDE 100

@interface WizardSprite ()
@property (nonatomic, strong) Units * units;

@property (nonatomic, strong) CCLabelTTF * label;
@property (nonatomic, strong) CCSprite * skin;
@property (nonatomic, strong) CCSprite * effect;

@property (nonatomic, strong) CCAction * hoverAction;
@end

@implementation WizardSprite

+(void)loadSprites {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"LOAD WIZARD SPRITES");
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard1-set2.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"wizard1-set2-animations.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard1-set1.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"wizard1-set1-animations.plist"];
    });
}


-(id)initWithPlayer:(Wizard *)player units:(Units *)units {
    if ((self=[super init])) {
        self.player = player;
        self.units = units;
        
        [WizardSprite loadSprites];

        // To use BatchNodes, you need to add the sprite TO the batch node
        // Then it only uses one draw call
//        [CCSpriteBatchNode batchNodeWithFile:@"wizard1-set1.png"];
//        [CCSpriteBatchNode batchNodeWithFile:@"wizard1-set2.png"]; 
        
        self.skin = [CCSprite node];
        [self addChild:self.skin];
            
//        self.label = [CCLabelTTF labelWithString:player.name fontName:@"Marker Felt" fontSize:18];
//        [self addChild:self.label];
        
        // BIND: state, position
        [self renderPosition];
        [self renderStatus];
        
        [[RACAble(self.player.position) distinctUntilChanged] subscribeNext:^(id x) {
            [self renderPosition];
        }];
        
        [[RACAble(self.player.state) distinctUntilChanged] subscribeNext:^(id x) {
            [self renderStatus];
        }];
        
        [[RACAble(self.player.effect) distinctUntilChanged] subscribeNext:^(id x) {
            [self renderEffect];
        }];
        
        [[RACAble(self.player.altitude) distinctUntilChanged] subscribeNext:^(id x) {
            [self renderAltitude];
        }];
    }
    return self;
}

-(CGPoint)calculatedPosition {
    return ccp([self.units toX:self.player.position], self.units.zeroY + PIXELS_HIGH_PER_ALTITUDE*self.player.altitude);
}

-(void)renderPosition {
    self.position = self.calculatedPosition;
    self.skin.flipX = (self.player.position == UNITS_MAX);
}

-(void)renderStatus {
    
    [self.skin stopAllActions];
    
    NSString * animationName = [NSString stringWithFormat:@"%@", self.stateAnimationName];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];
    NSAssert(animation, @"DID NOT LOAD ANIMATION");
    CCActionInterval * actionInterval = [CCAnimate actionWithAnimation:animation];
//        animation.restoreOriginalFrame = NO;
    [self.skin runAction:actionInterval];
    
//    NSString * imageName = [NSString stringWithFormat:@"%@.png", self.stateAnimationName];
//    [self.skin setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName]];
//    [self.skin runAction:self.stateAction];
}

- (void)renderEffect {
    
    if (self.effect) {
        [self removeChild:self.effect];
    }
    
    [self.skin stopAllActions];
    
    // set opactiy based on invisible
    if ([self.player.effect class] == [EffectInvisible class]) {
        [self.skin runAction:[CCFadeTo actionWithDuration:self.player.effect.delay opacity:40]];
    }
    else {
        [self.skin runAction:[CCFadeTo actionWithDuration:0.2 opacity:255]];
    }
    
    if ([self.player.effect class] == [EffectHelmet class]) {
        self.effect = [CCSprite spriteWithFile:@"helmet.png"];
        self.effect.flipX = self.player.position == UNITS_MAX;
        self.effect.position = ccp(-15*self.player.direction, 100);
        [self addChild:self.effect];
    }
    
    else if ([self.player.effect class] == [EffectHeal class]) {
//        self.skin.color = ccc3(255, 255, 255);
//        [self.skin setBlendFunc: (ccBlendFunc) { GL_ONE, GL_ONE }];
//        [self.skin runAction: [CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.9f scaleX:size.width scaleY:size.height], [CCScaleTo actionWithDuration:0.9f scaleX:size.width*0.75f scaleY:size. height*0.75f], nil] ]];
        
//        [self.skin runAction: [CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.9f opacity:150], [CCFadeTo actionWithDuration:0.9f opacity:255], nil]]];
        CCFiniteTimeAction * toRed = [CCTintTo actionWithDuration:1 red:230 green:130 blue:190];
        CCFiniteTimeAction * toNormal = [CCTintTo actionWithDuration:1 red:255 green:255 blue:255];
        CCAction * glowRed = [CCRepeatForever actionWithAction:[CCSequence actions:toRed, toNormal, nil]];
        [self.skin runAction:glowRed];
    }
    
    else if ([self.player.effect class] == [EffectSleep class]) {
        CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"wizard1-sleep"];
        NSAssert(animation, @"DID NOT LOAD ANIMATION");
        CCFiniteTimeAction * wait = [CCFadeTo actionWithDuration:0.2 opacity:255];
        CCActionInterval * actionInterval = [CCAnimate actionWithAnimation:animation];
        CCSequence * sequence = [CCSequence actions:wait, actionInterval, nil];
        [self.skin runAction:sequence];
        
        // then when the effect wears off, we need to re-render status
        CGPoint pos = self.calculatedPosition;
        self.rotation = -90.0;
        CCFiniteTimeAction * toPos = [CCMoveTo actionWithDuration:0.2 position:pos];
        CCFiniteTimeAction * rotate = [CCRotateTo actionWithDuration:0.2 angle:0.0];
        [self runAction:toPos];
        [self runAction:rotate];
    }
    
    else {
        self.skin.color = ccc3(255, 255, 255);
//        [self runAction:[CCMoveTo actionWithDuration:0.2 position:self.calculatedPosition]];
//        [self runAction:[CCRotateTo actionWithDuration:0.2 angle:0]];
        [self renderStatus];
        
    }

}

-(void)renderAltitude {
    CGPoint pos = self.calculatedPosition;
    CCFiniteTimeAction * toPos = [CCMoveTo actionWithDuration:0.2 position:ccp(pos.x, pos.y)];
    if (self.player.altitude > 0) {
        CCFiniteTimeAction * toHover = [CCMoveTo actionWithDuration:0.2 position:ccp(pos.x, pos.y+5)];
        self.hoverAction = [CCRepeatForever actionWithAction:[CCSequence actions:toPos, toHover, nil]];
        [self runAction:self.hoverAction];
    }
    else {
        [self stopAction:self.hoverAction];
        [self runAction:toPos];
    }
}

-(CCAction*)stateAction {
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:self.stateAnimationName];
    animation.restoreOriginalFrame = NO;
//    animation.delayPerUnit = 0.5;
    
    CCActionInterval * actionInterval = [CCAnimate actionWithAnimation:animation];
    CCAction * action = actionInterval;
    
    // only repeat ready?
//    if (self.player.state == PlayerStateReady) {
//        action = [CCRepeatForever actionWithAction:actionInterval];
//    }
    
    return action;
}


-(NSString*)stateAnimationName {
    NSString * stateName = @"prepare";
    
    if (self.player.state == PlayerStateCast)
        stateName = @"attack";
    
    else if(self.player.state == PlayerStateHit)
        stateName = @"damage";
    
    else if(self.player.state == PlayerStateDead)
        stateName = @"dead";
    
    return [NSString stringWithFormat:@"%@-%@", self.wizardSheetName, stateName];
}

-(NSString*)wizardSheetName {
    return [NSString stringWithFormat:@"wizard%@", self.player.wizardType];
}

@end
