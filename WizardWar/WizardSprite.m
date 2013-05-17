//
//  WizardSprite.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "WizardSprite.h"
#import "cocos2d.h"

@interface WizardSprite ()
@property (nonatomic, strong) Player * player;
@property (nonatomic, strong) Units * units;

@end

@implementation WizardSprite

-(id)initWithPlayer:(Player *)player units:(Units *)units {
    if ((self=[super init])) {
        self.player = player;
        self.units = units;
        self.contentSize = CGSizeMake(50, 50);
        self.position = ccp([self.units pixelsXForUnitPosition:player.position], self.units.groundY);
        NSLog(@"GOGO WIZRD %@ %f", NSStringFromCGPoint(self.position), player.position);
    }
    return self;
}

-(void)draw {
    ccDrawSolidRect(ccp(0, 0), ccp(self.contentSize.width,self.contentSize.height), ccc4f(1, 0, 0, 1));
}

@end
