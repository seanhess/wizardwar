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
@property (nonatomic, strong) CCSprite * skin;
@end

@implementation WizardSprite

-(id)initWithPlayer:(Player *)player units:(Units *)units {
    if ((self=[super init])) {
        self.player = player;
        self.player.delegate = self;
        self.units = units;
        self.position = ccp([self.units toX:player.position], self.units.zeroY);
        NSLog(@"GOGO WIZRD %@ %f", NSStringFromCGPoint(self.position), player.position);
        
        self.skin = [CCSprite spriteWithFile:@"wizard-1-prepare.png"];
        self.skin.scale = 0.75;
        [self addChild:self.skin];
        
//        self.label = [CCLabelTTF labelWithString:@"X" fontName:@"Marker Felt" fontSize:18];
//        self.label.position = ccp(self.contentSize.width / 2, self.contentSize.height/2);
//        [self addChild:self.label];
        
        [self render];
    }
    return self;
}

//-(void)draw {
//    ccDrawSolidRect(ccp(0, 0), ccp(self.contentSize.width,self.contentSize.height), ccc4f(1, 0, 0, 1));
//}

-(void)didUpdateForRender {
    [self render];
}

-(void)render {
//    [self.label setString:[NSString stringWithFormat:@"%i", self.player.health]];
    CCTexture2D * wizardImage = [self currentWizardImage];
//    self.skin.contentSize = wizardImage.contentSize;
//    NSLog(@"CONTENT SIZE %@", NSStringFromCGSize(wizardImage.contentSize));
    
    [self.skin setTexture:wizardImage];
}

-(CCTexture2D*)currentWizardImage {
    
    NSInteger wizardIndex = 2;
    
    if (!self.player.isFirstPlayer)
        wizardIndex = 1;
    
    NSString * stateName = @"prepare";
    
    if (self.player.state == PlayerStateCast)
        stateName = @"attack";
    
    else if(self.player.state == PlayerStateHit)
        stateName = @"damage";
    
    else if(self.player.state == PlayerStateDead)
        stateName = @"dead";
    
    return [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"wizard-%i-%@.png", wizardIndex, stateName]];
}

@end
