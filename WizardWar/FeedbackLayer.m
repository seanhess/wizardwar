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
@property (nonatomic, strong) CCSprite * spellSpriteParent;
@end

// Hmm... fancy pants
@implementation FeedbackLayer

-(id)init {
    self = [super init];
    if (self) {
        
        self.font = [[CCFontDefinition alloc] initWithFontName:FONT_COMIC_ZINE_SOLID fontSize:28];
        self.spellNameLabel = [CCLabelTTF labelWithString:@"" fontDefinition:self.font];
        self.spellNameLabel.horizontalAlignment = kCCTextAlignmentCenter;
        self.spellNameLabel.verticalAlignment = kCCVerticalTextAlignmentCenter;
        self.spellNameLabel.dimensions = CGSizeMake(200, 300);
        self.spellNameLabel.opacity = 0;
        
        [self addChild:self.spellNameLabel];
        
        __weak FeedbackLayer * wself = self;
        [[RACSignal combineLatest:@[RACAble(self.combos.hintedSpell), RACAble(self.combos.castDisabled)]] subscribeNext:^(id x) {
            [wself renderHintedSpell:wself.combos.hintedSpell];
        }];
//        [RACAble(self.combos.hintedSpell) subscribeNext:^(Spell*spell) {
//            
//        }];
    }
    return self;
}

-(void)renderHintedSpell:(Spell*)spell {
    
    BOOL hasHintedSpell = (spell != nil);
    
    [self.spellNameLabel stopAllActions];
    
    if (hasHintedSpell) {
        if ((!self.combos.castSpell && self.combos.hintedSpell && self.combos.castDisabled)) {
            [self.spellNameLabel setString:@"No Mana!"];
        } else {
            [self.spellNameLabel setString:spell.name];
        }
        
        
        [self.spellNameLabel runAction:[CCFadeTo actionWithDuration:FADE_IN opacity:255]];
    } else {
        [self.spellNameLabel runAction:[CCFadeTo actionWithDuration:FADE_OUT opacity:0]];
    }

}

@end
