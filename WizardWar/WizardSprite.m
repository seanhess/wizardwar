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
//        NSLog(@"GOGO WIZRD %@ %f", NSStringFromCGPoint(self.position), player.position);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard2.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard1.plist"];
        
        // the problem is the sprite sheet is set incorrectly
        // so you can't just update it with data
        // I could throw them into the same spritesheet?
        // no, that's lame
        
        // what if the appearances were randomly assigned?
        // we're going to have custom wizards later anyway
        
        // just make them both wizard 1?
        
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png", self.wizardSheetName]];
        [self addChild:self.spriteSheet];
        
        self.skin = [CCSprite spriteWithSpriteFrameName:self.currentWizardImage];
        [self.spriteSheet addChild:self.skin];
        
        [self render];
    }
    return self;
}

-(void)didUpdateForRender {
    [self render];
}

-(void)render {
    self.position = ccp([self.units toX:self.player.position], self.units.zeroY);
    
    // all wizard sprites should face the same direction
    NSString * imageName = self.currentWizardImage;
    [self.skin setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:imageName]];
    if (self.player.position == UNITS_MAX) self.skin.flipX = YES;
}

-(NSString*)currentWizardImage {
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
