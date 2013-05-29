//
//  LifeManaIndicatorNode.m
//  WizardWar
//
//  Created by Jake Gundersen on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "LifeManaIndicatorNode.h"
#import <ReactiveCocoa.h>

@interface LifeManaIndicatorNode()

@property (nonatomic, strong) NSMutableArray *emptyHearts;
@property (nonatomic, strong) NSMutableArray *filledHearts;
@property (nonatomic, strong) NSMutableArray *deadHearts;

@end

@implementation LifeManaIndicatorNode

-(id)init {
    if (self == [super init]) {
        CCSprite *backgroundBar = [CCSprite spriteWithFile:@"mana-container.png"];
        [self addChild:backgroundBar];
        
        self.emptyHearts = [NSMutableArray array];
        self.filledHearts = [NSMutableArray array];
        self.deadHearts = [NSMutableArray array];
        
        for (int i = 0; i < 5; i++) {
            CCSprite *heartDamage = [CCSprite spriteWithFile:@"heart-damage.png"];
            CCSprite *heartBlank = [CCSprite spriteWithFile:@"heart-empty.png"];
            CCSprite *heartFull = [CCSprite spriteWithFile:@"heart-full.png"];
            
            heartDamage.position = ccp(i * 25 + 25 - 75, 0);
            heartBlank.position = ccp(i * 25 + 25 - 75, 0);
            heartFull.position = ccp(i * 25 + 25 - 75, 0);
            
            [self.emptyHearts addObject:heartBlank];
            [self.filledHearts addObject:heartFull];
            [self.deadHearts addObject:heartDamage];
            
            // Order matters!
            // Blank -> Full -> Damage - if any are visible they can cover the others
            [self addChild:heartBlank];
            [self addChild:heartFull];
            [self addChild:heartDamage];
        }
        
        // OMG player doesn't even have to be set yet!!!!
        [[RACAble(self.player.health) distinctUntilChanged] subscribeNext:^(id value) {
            [self renderHealth];
        }];
        
        [[RACAble(self.player.mana) distinctUntilChanged] subscribeNext:^(id value) {
            [self renderMana];
        }];
        
        [[RACAble(self.match.status) distinctUntilChanged] subscribeNext:^(id value) {
            [self renderMatchStatus];
        }];
    }
    return self;
}

-(void)renderMana {
//    NSLog(@"RENDER MANA %i", self.player.mana);
    for (int i = 0; i < 5; i++) {
        CCSprite *heartFull = [self.filledHearts objectAtIndex:i];
        
        if (i <= self.player.mana - 1) {
            heartFull.opacity = 255;
        }
        else {
            heartFull.opacity = 0;
        }
    }
}

// rules: if health is down, heartDamage wins

-(void)renderHealth {
//    NSLog(@"RENDER HEALTH %i", self.player.health);
    for (int i = 0; i < 5; i++) {
        CCSprite *heartDamage = [self.deadHearts objectAtIndex:i];
        
        if (i <= self.player.health - 1) {
            heartDamage.opacity = 0;
        } else {
            heartDamage.opacity = 255;
        }
    }
}

-(void)renderMatchStatus {
    self.visible = self.match.status == MatchStatusPlaying;
}

@end
