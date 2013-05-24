//
//  LifeManaIndicatorNode.m
//  WizardWar
//
//  Created by Jake Gundersen on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "LifeManaIndicatorNode.h"

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
        
    }
    return self;
}

// set player can be called many times with the same value
-(void)setPlayer:(Player *)player {
    if (_player == player) return;
    [_player removeObserver:self forKeyPath:PLAYER_KEYPATH_MANA];
    [_player removeObserver:self forKeyPath:PLAYER_KEYPATH_HEALTH];
    
    _player = player;
    
    [player addObserver:self forKeyPath:PLAYER_KEYPATH_HEALTH options:NSKeyValueObservingOptionNew context:nil];
    [player addObserver:self forKeyPath:PLAYER_KEYPATH_MANA options:NSKeyValueObservingOptionNew context:nil];
    [self renderMana];
    [self renderHealth];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:PLAYER_KEYPATH_HEALTH]) [self renderHealth];
    else if ([keyPath isEqualToString:PLAYER_KEYPATH_MANA]) [self renderMana];
}

-(void)renderMana {
    NSLog(@"RENDER MANA %i", self.player.mana);
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
    NSLog(@"RENDER HEALTH %i", self.player.health);
    for (int i = 0; i < 5; i++) {
        CCSprite *heartDamage = [self.deadHearts objectAtIndex:i];
        
        if (i <= self.player.health - 1) {
            heartDamage.opacity = 0;
        } else {
            heartDamage.opacity = 255;
        }
    }
}

-(void)dealloc {
    self.player = nil;
}

@end
