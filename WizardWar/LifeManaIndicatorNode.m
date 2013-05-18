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
            
            [self addChild:heartDamage];
            [self addChild:heartFull];
            [self addChild:heartBlank];
        }
    }
    return self;
}

-(void)updateWithHealth:(NSInteger)health andMana:(NSInteger)mana
{
    for (int i = 0; i < 5; i++) {
        CCSprite *heartDamage = [self.deadHearts objectAtIndex:i];
        CCSprite *heartBlank = [self.emptyHearts objectAtIndex:i];
        CCSprite *heartFull = [self.filledHearts objectAtIndex:i];
        
        if (i <= mana) {
            heartFull.opacity = 255;
            heartDamage.opacity = 0;
            heartBlank.opacity = 0;
        } else if (i <= health) {
            heartFull.opacity = 0;
            heartDamage.opacity = 0;
            heartBlank.opacity = 255;
        } else {
            heartFull.opacity = 0;
            heartDamage.opacity = 255;
            heartBlank.opacity = 0;
        }
    }
}

@end
