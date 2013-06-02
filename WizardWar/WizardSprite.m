//
//  WizardSprite.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "WizardSprite.h"
#import "cocos2d.h"
#import "CCLabelTTF.h"
#import <ReactiveCocoa.h>

#define WIZARD_PADDING 20

@interface WizardSprite ()
@property (nonatomic, strong) Units * units;

@property (nonatomic, strong) CCLabelTTF * label;
@property (nonatomic, strong) CCSpriteBatchNode * spriteSheet;
@property (nonatomic, strong) CCSprite * skin;
@end

@implementation WizardSprite

+(void)loadSprites {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"LOAD WIZARD SPRITES");
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard2.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"wizard2-animation.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard1.plist"];
        [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"wizard1-animation.plist"];
    });
}


-(id)initWithPlayer:(Player *)player units:(Units *)units {
    if ((self=[super init])) {
        self.player = player;
        self.units = units;
        
        [WizardSprite loadSprites];
        
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png", self.wizardSheetName]];
        [self addChild:self.spriteSheet];
        
        self.skin = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png", self.stateAnimationName]];
        [self.spriteSheet addChild:self.skin];
        
//        self.label = [CCLabelTTF labelWithString:player.name fontName:@"Marker Felt" fontSize:18];
//        [self addChild:self.label];
        
        // BIND: state, position
        [self renderPosition];
        [self renderStatus];
        
        [[RACAble(self.player.position) distinctUntilChanged] subscribeNext:^(id x) {
            [self renderPosition];
        }];
        
        [[RACAble(self.player.state) distinctUntilChanged] subscribeNext:^(id x) {
            [self renderStatus];
        }];
    }
    return self;
}

-(void)renderPosition {
    self.position = ccp([self.units toX:self.player.position], self.units.zeroY);
    
    self.skin.flipX = (self.player.position == UNITS_MAX);
}

-(void)renderStatus {
    NSString * imageName = [NSString stringWithFormat:@"%@.png", self.stateAnimationName];
    [self.skin setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName]];
    [self.skin runAction:self.stateAction];
}

-(CCAction*)stateAction {
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:self.stateAnimationName];
    animation.restoreOriginalFrame = NO;
//    animation.delayPerUnit = 0.5;
    
    CCActionInterval * actionInterval = [CCAnimate actionWithAnimation:animation];
    CCAction * action = actionInterval;
    
    // only repeat ready?
//    if (self.player.state == PlayerStateReady) {
//        action = [CCRepeatForever actionWithAction:actionInterval];
//    }
    
    return action;
}

-(NSString*)stateAnimationName {
    NSString * stateName = @"prepare";
    
    if (self.player.state == PlayerStateCast)
        stateName = @"attack";
    
    else if(self.player.state == PlayerStateHit)
        stateName = @"damage";
    
    else if(self.player.state == PlayerStateDead)
        stateName = @"dead";
    
    return [NSString stringWithFormat:@"%@-%@", self.wizardSheetName, stateName];
}

-(NSString*)wizardSheetName {
    return [NSString stringWithFormat:@"wizard%@", self.player.wizardType];
}

@end
