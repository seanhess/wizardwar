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
@property (nonatomic, strong) CCLayer * debugLabelLayer;
@end


@implementation ChatBubbleSprite

-(id)init {
    if ((self = [super init])) {
        self.background = [CCSprite spriteWithSpriteFrameName:@"chat-bubble.png"];
        self.background.scale = 0.8;
        [self addChild:self.background];
        
        self.label = [CCLabelTTF labelWithString:@"hello" fontName:FONT_LOVEYA fontSize:12.0];
        self.label.dimensions = CGSizeMake(200, 300);
        self.label.horizontalAlignment = NSTextAlignmentCenter;
        self.label.verticalAlignment = NSTextAlignmentCenter;
        self.label.color = ccc3(0, 0, 0);
//        self.label.position = ccp(-50, 50);
        
//        self.debugLabelLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 255, 100) width:self.label.dimensions.width height:self.label.dimensions.height];
////        self.debugLabelLayer.position = ccp(-self.debugLabelLayer.contentSize.width/2, -self.debugLabelLayer.contentSize.height/2);
//        [self addChild:self.debugLabelLayer];
        
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
