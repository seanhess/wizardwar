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
#import "EffectUndies.h"

#define WIZARD_PADDING 20
#define PIXELS_HIGH_PER_ALTITUDE 100

@interface WizardSprite ()
@property (nonatomic, strong) Units * units;

@property (nonatomic, strong) CCLabelTTF * label;
@property (nonatomic, strong) CCSprite * skin;
@property (nonatomic, strong) CCSprite * clothes;
@property (nonatomic, strong) CCSprite * effect;

@property (nonatomic, strong) CCAction * hoverAction;

@property (nonatomic, strong) Match * match;
@property (nonatomic) BOOL isCurrentWizard;


@property (nonatomic, strong) CCAction * skinStatusAction;
@property (nonatomic, strong) CCAction * clothesStatusAction;

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

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard1-set1-clothes.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"wizard1-set1-clothes-animations.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard1-set2-clothes.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"wizard1-set2-clothes-animations.plist"];

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
        self.clothes = [CCSprite node];
        ccColor3B color = [self colorWithColor:wizard.color];
        NSLog(@"WIZARD COLOR %i %i %i", color.r, color.g, color.b);
        self.clothes.color = color;
        [self addChild:self.skin];
        [self addChild:self.clothes];
        
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

-(ccColor3B)colorWithColor:(UIColor*)color {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return ccc3((int)(red * 255), (int)(green * 255), (int)(blue * 255));
}

-(CGPoint)calculatedPosition {
    return ccp([self.units toX:self.wizard.position], [self.units altitudeY:self.wizard.altitude]);
}

-(void)renderPosition {
    self.position = self.calculatedPosition;
    self.skin.flipX = (self.wizard.position == UNITS_MAX);
    self.clothes.flipX = self.skin.flipX;
}

-(void)renderStatus {
    
    if (self.wizard.effect.class == EffectSleep.class && (self.wizard.state == WizardStatusReady || self.wizard.state == WizardStatusHit || self.wizard.state == WizardStatusCast))
        return;
    
//    NSLog(@"RENDER STATUS %@ = %i", self.wizard.name, self.wizard.state);
    // I should remove all status actions, not all actions
//    [self.skin stopAllActions];
//    [self.clothes stopAllActions];
    
    [self.skin stopAction:self.skinStatusAction];
    self.skinStatusAction = [self animationForStatus:self.wizard.state clothes:NO];
    [self.skin runAction:self.skinStatusAction];

    [self.clothes stopAction:self.clothesStatusAction];
    self.clothesStatusAction = [self animationForStatus:self.wizard.state clothes:YES];
    [self.clothes runAction:self.clothesStatusAction];
    
//    NSString * imageName = [NSString stringWithFormat:@"%@.png", @"wizard1-sleep1"];
//    [self.skin setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName]];
}

-(CCAction*)animationForStatus:(WizardStatus)status clothes:(BOOL)isClothes {
    NSString * clothesSuffix = (isClothes) ? @"-clothes" : @"";
    NSString * animationName = [NSString stringWithFormat:@"%@%@", [self animationNameForStatus:status], clothesSuffix];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];
    NSAssert(animation, @"DID NOT LOAD ANIMATION");
    CCActionInterval * actionInterval = [CCAnimate actionWithAnimation:animation];
    CCAction * action = actionInterval;
    
    if (self.wizard.state == WizardStatusReady || self.wizard.state == WizardStatusWon)
        action = [CCRepeatForever actionWithAction:actionInterval];
    
    return action;
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
    
//    NSLog(@"RENDER EFFECT %@ = %@", self.wizard.name, self.wizard.effect);
    
    [self.skin stopAllActions];
    [self.clothes stopAllActions];
    self.skin.opacity = 255;
    self.clothes.opacity = 255;
    
    // set opactiy based on invisible
    if ([self.wizard.effect class] == [EffectInvisible class]) {
        [self.skin runAction:[CCFadeTo actionWithDuration:self.wizard.effect.delay opacity:20]];
        [self.clothes runAction:[CCFadeTo actionWithDuration:self.wizard.effect.delay opacity:20]];
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
        CCFiniteTimeAction * toRed = [CCTintTo actionWithDuration:1 red:255 green:100 blue:100];
        CCFiniteTimeAction * toNormal = [CCTintTo actionWithDuration:1 red:255 green:255 blue:255];
        CCAction * glowRed = [CCRepeatForever actionWithAction:[CCSequence actions:toRed, toNormal, nil]];
        [self.skin runAction:glowRed];
//        [self.clothes runAction:glowRed];
    }
    
    else if ([self.wizard.effect class] == [EffectSleep class]) {
        [self.skin runAction:[self actionForSleepEffectForClothes:NO]];
        [self.clothes runAction:[self actionForSleepEffectForClothes:YES]];
        
        // then when the effect wears off, we need to re-render status
        CGPoint pos = self.calculatedPosition;
        self.rotation = -90.0;
        CCFiniteTimeAction * toPos = [CCMoveTo actionWithDuration:0.2 position:pos];
        CCFiniteTimeAction * rotate = [CCRotateTo actionWithDuration:0.2 angle:0.0];
        [self runAction:toPos];
        [self runAction:rotate];
    }
    
    else if ([self.wizard.effect class] == [EffectUndies class]) {
        self.effect = [CCSprite spriteWithFile:@"wizard-undies.png"];
//        self.effect.flipY = YES;
        self.effect.position = ccp(self.wizard.direction*-15, -34);
        [self addChild:self.effect];
    }
    
    else {
        self.skin.color = ccc3(255, 255, 255);
//        self.clothes.color = [self colorWithColor:self.wizard.color];
//        [self runAction:[CCMoveTo actionWithDuration:0.2 position:self.calculatedPosition]];
//        [self runAction:[CCRotateTo actionWithDuration:0.2 angle:0]];
        [self renderStatus];
        
    }
}

-(CCAction*)actionForSleepEffectForClothes:(BOOL)isClothes {
    NSString * clothesSuffix = (isClothes) ? @"-clothes" : @"";
    NSString * animationName = [NSString stringWithFormat:@"wizard1-sleep%@", clothesSuffix];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];
    NSAssert(animation, @"DID NOT LOAD ANIMATION");
    CCFiniteTimeAction * wait = [CCFadeTo actionWithDuration:0.2 opacity:255];
    CCActionInterval * actionInterval = [CCAnimate actionWithAnimation:animation];
    CCActionInterval * sleep = [CCRepeat actionWithAction:actionInterval times:10000];
    CCSequence * sequence = [CCSequence actions:wait, sleep, nil];
    return sequence;
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


-(NSString*)animationNameForStatus:(WizardStatus)status {
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
