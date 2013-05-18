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

#define WIZARD_PADDING 20

@interface WizardSprite ()
@property (nonatomic, strong) Player * player;
@property (nonatomic, strong) Units * units;

@property (nonatomic, strong) CCLabelTTF * label;
@property (nonatomic, strong) CCSpriteBatchNode * spriteSheet;
@property (nonatomic, strong) CCSprite * skin;
@end

@implementation WizardSprite

-(id)initWithPlayer:(Player *)player units:(Units *)units {
    if ((self=[super init])) {
        self.player = player;
        self.player.delegate = self;
        self.units = units;
        self.position = ccp([self.units toX:player.position], self.units.zeroY);
//        NSLog(@"GOGO WIZRD %@ %f", NSStringFromCGPoint(self.position), player.position);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard2.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard1.plist"];
        
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png", self.wizardIndexName]];
        [self addChild:self.spriteSheet];
        
        [self render];
    }
    return self;
}

-(void)didUpdateForRender {
    [self render];
}

-(void)render {
    [self.spriteSheet removeAllChildren];
    NSString * imageName = self.currentWizardImage;
    self.skin = [CCSprite spriteWithSpriteFrameName:imageName];
    [self.spriteSheet addChild:self.skin];
}

-(NSString*)currentWizardImage {
    NSString * stateName = @"prepare";
    
    if (self.player.state == PlayerStateCast)
        stateName = @"attack";
    
    else if(self.player.state == PlayerStateHit)
        stateName = @"damage";
    
    else if(self.player.state == PlayerStateDead)
        stateName = @"dead";
    
    return [NSString stringWithFormat:@"%@-%@", self.wizardIndexName, stateName];
}

-(NSInteger)wizardIndex {
    if (!self.player.isFirstPlayer)
        return 1;
    else
        return 2;
}

-(NSString*)wizardIndexName {
    return [NSString stringWithFormat:@"wizard%i", self.wizardIndex];
}

@end
