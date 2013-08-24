//
//  EnvironmentLayer.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "EnvironmentLayer.h"
#import "cocos2d.h"
#import "NSArray+Functional.h"

@interface EnvironmentLayer ()
@property (nonatomic, strong) CCSprite * background;
@end

@implementation EnvironmentLayer

-(id)init {
    if ((self = [super init])) {

        
    }
    return self;
}

-(void)setEnvironment:(NSString *)environment {
    [self removeAllChildren];
    
    if (!environment) environment = @[ENVIRONMENT_CAVE, ENVIRONMENT_CASTLE, ENVIRONMENT_EVIL_FOREST, ENVIRONMENT_ICE_CAVE].randomItem;

    NSInteger device = [[CCConfiguration sharedConfiguration] runningDevice];
    if (device == kCCDeviceiPadRetinaDisplay || device == kCCDeviceiPad) {
        self.background = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@-ipad.png", environment]];
    } else {
        self.background = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", environment]];
    }
    self.background.anchorPoint = ccp(0,0);
    [self addChild:self.background];
}

@end
