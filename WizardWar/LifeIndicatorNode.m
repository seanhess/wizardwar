//
//  LifeManaIndicatorNode.m
//  WizardWar
//
//  Created by Jake Gundersen on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "LifeIndicatorNode.h"
#import "EffectHeal.h"
#import "NSArray+Functional.h"
#import <ReactiveCocoa.h>

@interface LifeIndicatorNode()

@property (nonatomic, strong) NSMutableArray *emptyHearts;
@property (nonatomic, strong) NSMutableArray *filledHearts;

@property (nonatomic, strong) CCAction * healAction;

@end

@implementation LifeIndicatorNode

-(id)init {
    if (self == [super init]) {
        CCSprite *backgroundBar = [CCSprite spriteWithFile:@"mana-container.png"];
        [self addChild:backgroundBar];
        
        self.emptyHearts = [NSMutableArray array];
        self.filledHearts = [NSMutableArray array];
        
        for (int i = 0; i < 5; i++) {
            CCSprite *heartBlank = [CCSprite spriteWithFile:@"heart-empty.png"];
            CCSprite *heartFull = [CCSprite spriteWithFile:@"heart-full.png"];
            
            heartBlank.position = ccp(i * 25 + 25 - 75, 0);
            heartFull.position = ccp(i * 25 + 25 - 75, 0);
            
            heartFull.scale = 0;
            
            [self.emptyHearts addObject:heartBlank];
            [self.filledHearts addObject:heartFull];
            
            // Blank -> Full
            [self addChild:heartBlank];
            [self addChild:heartFull];
        }
        
//        CCSequence * blinkSequence = [CCSequence actions:[CCFadeTo actionWithDuration:0.5 opacity:255], [CCFadeTo actionWithDuration:0.5 opacity:0], nil];
//        [CCRepeatForever actionWithAction:blinkSequence];
        self.healAction = [CCScaleTo actionWithDuration:EFFECT_HEAL_TIME scale:0.8];
        
        // OMG player doesn't even have to be set yet!!!!
        [[RACAble(self.player.health) distinctUntilChanged] subscribeNext:^(id value) {
            [self renderHealth];
        }];
        
        [[RACAble(self.player.effect) distinctUntilChanged] subscribeNext:^(id value) {
            [self renderEffect];
        }];
        
        [[RACAble(self.match.status) distinctUntilChanged] subscribeNext:^(id value) {
            [self renderMatchStatus];
        }];
    }
    return self;
}

-(void)animateIn:(CCSprite*)sprite {
    if (sprite.scale < 1) {
        CCAction * large = [CCScaleTo actionWithDuration:0.2 scale:1.2];
        CCAction * small = [CCScaleTo actionWithDuration:0.2 scale:1.0];
        CCSequence * sequence = [CCSequence actionWithArray:@[large, small]];
        [sprite runAction:sequence];
        sprite.opacity = 255;
    }
}

-(void)animateOut:(CCSprite*)sprite {
    [sprite runAction:[CCScaleTo actionWithDuration:0.2 scale:0.0]];
}

// rules: if health is down, heartDamage wins
// crap, when you heal up, you need to render effect again :(

-(void)renderHealth {
    for (int i = 0; i < 5; i++) {
        CCSprite *heartFull = [self.filledHearts objectAtIndex:i];
        [heartFull stopAction:self.healAction];
        if (i <= self.player.health - 1) {
            [self animateIn:heartFull];
        } else {
            [self animateOut:heartFull];
        }
    }
}

-(void)renderEffect {
    if ([self.player.effect class] == [EffectHeal class]) {
        if (self.player.health < MAX_HEALTH) {
            CCSprite * nextHeart = [self.filledHearts objectAtIndex:self.player.health];
            [nextHeart runAction:self.healAction];
        }        
    }
    else {
        [self.filledHearts forEach:^(CCSprite * sprite) {
            [sprite stopAction:self.healAction];
        }];
    }
}

-(void)renderMatchStatus {
    self.visible = self.match.status == MatchStatusPlaying;
}

@end
