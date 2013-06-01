//
//  LifeManaIndicatorNode.m
//  WizardWar
//
//  Created by Jake Gundersen on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "LifeIndicatorNode.h"
#import <ReactiveCocoa.h>

@interface LifeIndicatorNode()

@property (nonatomic, strong) NSMutableArray *emptyHearts;
@property (nonatomic, strong) NSMutableArray *filledHearts;

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
            
            heartFull.opacity = 0;
            
            [self.emptyHearts addObject:heartBlank];
            [self.filledHearts addObject:heartFull];
            
            // Blank -> Full
            [self addChild:heartBlank];
            [self addChild:heartFull];
        }
        
        // OMG player doesn't even have to be set yet!!!!
        [[RACAble(self.player.health) distinctUntilChanged] subscribeNext:^(id value) {
            [self renderHealth];
        }];
        
        [[RACAble(self.match.status) distinctUntilChanged] subscribeNext:^(id value) {
            [self renderMatchStatus];
        }];
    }
    return self;
}

-(void)animateIn:(CCSprite*)sprite {
    if (sprite.opacity == 0) {
//        CCAction * fade = [CCFadeIn actionWithDuration:0.2];
        CCAction * large = [CCScaleTo actionWithDuration:0.2 scale:1.2];
        CCAction * small = [CCScaleTo actionWithDuration:0.2 scale:1.0];
        sprite.scale = 0.1;
        CCSequence * sequence = [CCSequence actionWithArray:@[large, small]];
        [sprite runAction:sequence];
        sprite.opacity = 255;
    }
}

-(void)animateOut:(CCSprite*)sprite {
    if (sprite.opacity == 255) {
        [sprite runAction:[CCFadeOut actionWithDuration:0.2]];
    }
}

// rules: if health is down, heartDamage wins

-(void)renderHealth {
//    NSLog(@"RENDER HEALTH %i", self.player.health);
    for (int i = 0; i < 5; i++) {
        CCSprite *heartFull = [self.filledHearts objectAtIndex:i];
        if (i <= self.player.health - 1) {
            [self animateIn:heartFull];
        } else {
            [self animateOut:heartFull];
        }
    }
}

-(void)renderMatchStatus {
    self.visible = self.match.status == MatchStatusPlaying;
}

@end
