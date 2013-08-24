//
//  ChatBubbleSprite.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "ChatBubbleSprite.h"
#import "cocos2d.h"
#import "AppStyle.h"

@interface ChatBubbleSprite ()
@property (nonatomic, strong) CCSprite * background;
@property (nonatomic, strong) CCLabelTTF * label;
@end


@implementation ChatBubbleSprite

-(id)init {
    if ((self = [super init])) {
        self.background = [CCSprite spriteWithSpriteFrameName:@"chat-bubble.png"];
        self.background.scale = 0.5;
        [self addChild:self.background];
        
        self.label = [CCLabelTTF labelWithString:@"hello" fontName:FONT_LOVEYA fontSize:12.0];
        self.label.color = ccc3(0, 0, 0);
        [self addChild:self.label];
    }
    return self;
}

-(void)setMessage:(NSString *)message {
    _message = message;
    if (!message) message = @"";
    [self.label setString:message];
}

-(void)setFlipX:(BOOL)flipX {
    self.background.flipX = flipX;
}

@end
