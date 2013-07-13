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
#import "AppStyle.h"

#define WIZARD_PADDING 20
#define PIXELS_HIGH_PER_ALTITUDE 100

@interface WizardSprite ()
@property (nonatomic, strong) Units * units;

@property (nonatomic, strong) CCLabelTTF * label;
@property (nonatomic, strong) CCSprite * skin;
//@property (nonatomic, strong) CCSprite * clothes;
@property (nonatomic, strong) CCSprite * effect;

@property (nonatomic, strong) CCAction * hoverAction;

@property (nonatomic, strong) Match * match;
@property (nonatomic) BOOL isCurrentWizard;


@end

@implementation WizardSprite

+(void)loadSprites {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"LOAD WIZARD SPRITES");
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard1-set1.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"wizard1-set1-animations.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard1-set2.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"wizard1-set2-animations.plist"];

//        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard1-set1-clothes.plist"];
//        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"wizard1-set1-clothes-animations.plist"];
//        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard1-set2-clothes.plist"];
//        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"wizard1-set2-clothes-animations.plist"];

    });
}


-(id)initWithWizard:(Wizard *)wizard units:(Units *)units match:(Match*)match isCurrentWizard:(BOOL)isCurrentWizard {
    if ((self=[super init])) {
        self.wizard = wizard;
        self.units = units;
        self.match = match;
        self.isCurrentWizard = isCurrentWizard;
        
        [WizardSprite loadSprites];

        // To use BatchNodes, you need to add the sprite TO the batch node
        // Then it only uses one draw call
        // see SpellSprite
//        [CCSpriteBatchNode batchNodeWithFile:@"wizard1-set1.png"];
//        [CCSpriteBatchNode batchNodeWithFile:@"wizard1-set2.png"];
        
        __weak WizardSprite * wself = self;
        
        self.skin = [CCSprite node];
//        self.clothes = [CCSprite node];
        [self addChild:self.skin];
//        [self addChild:self.clothes];
        
        // I need to only show this if the game hasn't started!
        self.label = [CCLabelTTF labelWithString:self.wizardName fontName:FONT_COMIC_ZINE fontSize:36];
        self.label.position = ccp(0, 130);
        [self addChild:self.label];
        
        // BIND: state, position
        [self renderPosition];
        [self renderStatus];
        [self renderMatchStatus];
        
        [[RACAble(self.wizard.position) distinctUntilChanged] subscribeNext:^(id x) {
            [wself renderPosition];
        }];
        
        [[RACAble(self.wizard.state) distinctUntilChanged] subscribeNext:^(id x) {
            [wself renderStatus];
        }];
        
        [[RACAble(self.wizard.effect) distinctUntilChanged] subscribeNext:^(id x) {
            [wself renderEffect];
        }];
        
        [[RACAble(self.wizard.altitude) distinctUntilChanged] subscribeNext:^(id x) {
            [wself renderAltitude];
        }];
        
        [[RACAble(self.match.status) distinctUntilChanged] subscribeNext:^(id x) {
            [wself renderMatchStatus];
        }];
    }
    return self;
}

-(CGPoint)calculatedPosition {
    return ccp([self.units toX:self.wizard.position], self.units.zeroY + PIXELS_HIGH_PER_ALTITUDE*self.wizard.altitude);
}

-(void)renderPosition {
    self.position = self.calculatedPosition;
    self.skin.flipX = (self.wizard.position == UNITS_MAX);
//    self.clothes.flipX = self.skin.flipX;
}

-(void)renderStatus {
    
    if (self.wizard.effect.class == EffectSleep.class && (self.wizard.state == WizardStatusReady || self.wizard.state == WizardStatusHit || self.wizard.state == WizardStatusCast))
        return;
    
    [self.skin stopAllActions];
    
    NSString * animationName = [NSString stringWithFormat:@"%@", self.stateAnimationName];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];
    NSAssert(animation, @"DID NOT LOAD ANIMATION");
    CCActionInterval * actionInterval = [CCAnimate actionWithAnimation:animation];
    CCAction * action = actionInterval;
    
    if (self.wizard.state == WizardStatusReady || self.wizard.state == WizardStatusWon)
        action = [CCRepeatForever actionWithAction:actionInterval];
    
    [self.skin runAction:action];
    
//    NSString * imageName = [NSString stringWithFormat:@"%@.png", @"wizard1-sleep1"];
//    [self.skin setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName]];
}

- (void)renderMatchStatus {
    if ((self.match.status == MatchStatusReady || self.match.status == MatchStatusSyncing) && self.isCurrentWizard)
        self.skin.color = ccc3(0, 255, 0);
    else
        self.skin.color = ccWHITE;
    
    self.label.visible = (self.match.status == MatchStatusReady || self.match.status == MatchStatusSyncing);
}

- (NSString*)wizardName {
    if (self.isCurrentWizard) return @"You";
    else return self.wizard.name;
}

- (void)renderEffect {
    
    if (self.effect) {
        [self removeChild:self.effect];
    }
    
    [self.skin stopAllActions];
    self.skin.opacity = 255;
    
    // set opactiy based on invisible
    if ([self.wizard.effect class] == [EffectInvisible class]) {
        [self.skin runAction:[CCFadeTo actionWithDuration:self.wizard.effect.delay opacity:20]];
    }
    
    else if ([self.wizard.effect class] == [EffectHelmet class]) {
        self.effect = [CCSprite spriteWithFile:@"helmet.png"];
        self.effect.flipX = self.wizard.position == UNITS_MAX;
        self.effect.position = ccp(-4*self.wizard.direction, 80);
        [self addChild:self.effect];
    }
    
    else if ([self.wizard.effect class] == [EffectHeal class]) {
//        self.skin.color = ccc3(255, 255, 255);
//        [self.skin setBlendFunc: (ccBlendFunc) { GL_ONE, GL_ONE }];
//        [self.skin runAction: [CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.9f scaleX:size.width scaleY:size.height], [CCScaleTo actionWithDuration:0.9f scaleX:size.width*0.75f scaleY:size. height*0.75f], nil] ]];
        
//        [self.skin runAction: [CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.9f opacity:150], [CCFadeTo actionWithDuration:0.9f opacity:255], nil]]];
        CCFiniteTimeAction * toRed = [CCTintTo actionWithDuration:1 red:230 green:130 blue:190];
        CCFiniteTimeAction * toNormal = [CCTintTo actionWithDuration:1 red:255 green:255 blue:255];
        CCAction * glowRed = [CCRepeatForever actionWithAction:[CCSequence actions:toRed, toNormal, nil]];
        [self.skin runAction:glowRed];
    }
    
    else if ([self.wizard.effect class] == [EffectSleep class]) {
        CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"wizard1-sleep"];
        NSAssert(animation, @"DID NOT LOAD ANIMATION");
        CCFiniteTimeAction * wait = [CCFadeTo actionWithDuration:0.2 opacity:255];
        CCActionInterval * actionInterval = [CCAnimate actionWithAnimation:animation];
        CCActionInterval * sleep = [CCRepeat actionWithAction:actionInterval times:10000];
        CCSequence * sequence = [CCSequence actions:wait, sleep, nil];
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
    if (self.wizard.altitude > 0) {
        CCFiniteTimeAction * toHover = [CCMoveTo actionWithDuration:0.2 position:ccp(pos.x, pos.y+5)];
        self.hoverAction = [CCRepeatForever actionWithAction:[CCSequence actions:toPos, toHover, nil]];
        [self runAction:self.hoverAction];
    }
    else {
        [self stopAction:self.hoverAction];
        [self runAction:toPos];
    }
}


-(NSString*)stateAnimationName {
    NSString * stateName = @"prepare";
    
    if (self.wizard.state == WizardStatusCast)
        stateName = @"attack";
    
    else if(self.wizard.state == WizardStatusHit)
        stateName = @"damage";
    
    else if(self.wizard.state == WizardStatusDead)
        stateName = @"dead";
    
    else if(self.wizard.state == WizardStatusWon)
        stateName = @"celebrate";
    
    return [NSString stringWithFormat:@"%@-%@", self.wizardSheetName, stateName];
}

-(NSString*)wizardSheetName {
    return [NSString stringWithFormat:@"wizard%@", self.wizard.wizardType];
}

@end
