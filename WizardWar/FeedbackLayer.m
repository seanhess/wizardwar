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

@interface FeedbackLayer ()
@property (nonatomic, strong) CCLabelTTF * spellNameLabel;
@property (nonatomic, strong) CCFontDefinition * font;
@property (nonatomic, strong) CCSprite * spellSprite;
@end

// Hmm... fancy pants
@implementation FeedbackLayer

-(id)init {
    self = [super init];
    if (self) {
        
        self.spellSprite = [CCSprite node];
        [self addChild:self.spellSprite];
        
        self.font = [[CCFontDefinition alloc] initWithFontName:FONT_COMIC_ZINE_SOLID fontSize:24];
        self.spellNameLabel = [CCLabelTTF labelWithString:@"Hello" fontDefinition:self.font];
        self.spellNameLabel.position = ccp(0, -40);
        [self addChild:self.spellNameLabel];
    }
    return self;
}

@end
