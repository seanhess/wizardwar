//
//  FeedbackLayer.m
//  WizardWar
//
//  Created by Sean Hess on 7/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "FeedbackLayer.h"
#import <cocos2d.h>
#import "AppStyle.h"
#import <ReactiveCocoa.h>
#import "Spell.h"
#import "SpellSprite.h"

#define FADE_IN 0.2
#define FADE_OUT 0.5

@interface FeedbackLayer ()
@property (nonatomic, strong) CCLabelTTF * spellNameLabel;
@property (nonatomic, strong) CCFontDefinition * font;
@property (nonatomic, strong) CCSprite * spellSprite;
@property (nonatomic, strong) CCSprite * bigXSprite;
@property (nonatomic, strong) CCSprite * spellSpriteParent;
@end

// Hmm... fancy pants
@implementation FeedbackLayer

-(id)init {
    self = [super init];
    if (self) {
        
        [SpellSprite loadSprites];
        
//        self.spellSprite = [CCSprite node];
//        self.spellSprite.contentSize = CGSizeMake(40, 40);
//        [self addChild:self.spellSprite];
//        self.spellSprite.position = ccp(0, 10);
        
//        self.bigXSprite = [CCSprite spriteWithFile:@"bigx.png"];
//        self.bigXSprite.color = ccc3(255, 0, 0);
//        self.bigXSprite.visible = NO;
//        [self addChild:self.bigXSprite];        
//        
//        self.spellSpriteParent = [CCSprite node];
//        [self addChild:self.spellSpriteParent];
        
        self.font = [[CCFontDefinition alloc] initWithFontName:FONT_COMIC_ZINE_SOLID fontSize:28];
        self.spellNameLabel = [CCLabelTTF labelWithString:@"" fontDefinition:self.font];
        self.spellNameLabel.horizontalAlignment = kCCTextAlignmentCenter;
        self.spellNameLabel.verticalAlignment = kCCVerticalTextAlignmentCenter;
        self.spellNameLabel.dimensions = CGSizeMake(200, 300);
        self.spellNameLabel.opacity = 0;
        
        [self addChild:self.spellNameLabel];
        
        

        __weak FeedbackLayer * wself = self;
        [RACAble(self.combos.hintedSpell) subscribeNext:^(Spell*spell) {
            [wself renderHintedSpell:spell];
        }];
    }
    return self;
}

-(void)renderHintedSpell:(Spell*)spell {
    
    BOOL hasHintedSpell = (spell != nil);
    
//    NSString * labelText = @"";
//    self.spellNameLabel.color = ccc3(255, 255, 255);
//    self.bigXSprite.visible = NO;
//    NSLog(@"STOPPING %i", self.spellNameLabel.opacity);
    [self.spellNameLabel stopAllActions];
//    NSLog(@"STOPPING %i", self.spellNameLabel.opacity);
    
    if (hasHintedSpell) {
        [self.spellNameLabel setString:spell.name];
        [self.spellNameLabel runAction:[CCFadeTo actionWithDuration:FADE_IN opacity:255]];
    } else {
        [self.spellNameLabel runAction:[CCFadeTo actionWithDuration:FADE_OUT opacity:0]];
    }
    
//        [self.spellSpriteParent removeChild:self.spellSprite];
//        
//        CCSprite * sprite = [CCSprite node];
//        
//        if ([SpellSprite isSingleImage:spell]) {
//            sprite = [SpellSprite singleImage:spell];
//        } else if (![SpellSprite isNoRender:spell]){
//            NSString * animationName = [SpellSprite castAnimationName:spell];
//            CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:animationName];
//            NSInteger frameIndex = (animation.frames.count / 2);
//            CCSpriteFrame *frame = [[animation.frames objectAtIndex:frameIndex] spriteFrame];
//            
//            [sprite setDisplayFrame:frame];
//        }
//        
//        CGSize size = sprite.contentSize;
//        sprite.scale = 80 / size.height;
//        self.spellSprite = sprite;
//        self.spellSprite.position = ccp(0, 10);
//        [self.spellSpriteParent addChild:self.spellSprite];
//        [self.spellSprite runAction:[CCFadeTo actionWithDuration:FADE_IN opacity:255]];
//        
//        if (self.combos.sameSpellTwice) {
//            labelText = [NSString stringWithFormat:@"Too Much %@!", spell.name];
////            self.spellNameLabel.position = ccp(0, -80);
//            self.bigXSprite.visible = YES;
//        } else {
//            labelText = [NSString stringWithFormat:@"%@", spell.name];
//            self.spellNameLabel.position = ccp(0, -50);
//        }
//        
//        self.spellNameLabel.position = ccp(0, -40);
//        
//    } else {
//        [self.spellSprite runAction:[CCFadeTo actionWithDuration:FADE_OUT opacity:0]];
//        
//        if (self.combos.allElements.count == 1)
//            labelText = @"Drag to connect elements";
//        
//        else if (self.combos.allElements.count == 2)
//            labelText = @"Keep going!";
//        
//        self.spellNameLabel.position = ccp(0, 0);
//    }
//
//    [self.spellNameLabel setString:labelText];
//    if (labelText.length) {
//        NSLog(@" - fade in");
////        [self.spellNameLabel runAction:[CCFadeTo actionWithDuration:FADE_IN opacity:255]];
//        self.spellNameLabel.opacity = 255;
//    } else {
//        NSLog(@" - fade out %i", self.spellNameLabel.opacity);
//        self.spellNameLabel.opacity = 255;
////        [self.spellNameLabel runAction:[CCFadeTo actionWithDuration:FADE_OUT opacity:255]];
//    }
//    

}

@end
