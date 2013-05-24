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
        self.units = units;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard2.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"wizard1.plist"];
        
        self.spriteSheet = [CCSpriteBatchNode batchNodeWithFile:[NSString stringWithFormat:@"%@.png", self.wizardSheetName]];
        [self addChild:self.spriteSheet];
        
        self.skin = [CCSprite spriteWithSpriteFrameName:self.currentWizardImage];
        [self.spriteSheet addChild:self.skin];
        
        // BIND: state, position
        [self renderPosition];
        [self renderStatus];
        
        [self.player addObserver:self forKeyPath:PLAYER_KEYPATH_POSITION options:NSKeyValueObservingOptionNew context:nil];
        [self.player addObserver:self forKeyPath:PLAYER_KEYPATH_STATUS options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:PLAYER_KEYPATH_STATUS]) [self renderStatus];
    else if ([keyPath isEqualToString:PLAYER_KEYPATH_POSITION]) [self renderPosition];
}

-(void)renderPosition {
    self.position = ccp([self.units toX:self.player.position], self.units.zeroY);
}

-(void)renderStatus {
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

-(void)dealloc {
    [self.player removeObserver:self forKeyPath:PLAYER_KEYPATH_STATUS];
    [self.player removeObserver:self forKeyPath:PLAYER_KEYPATH_POSITION];
}

@end
