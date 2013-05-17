//
//  MatchGroundLayer.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "MatchGroundSprite.h"

@implementation MatchGroundSprite

-(void)draw {
    ccDrawSolidRect(ccp(0, 0), ccp(self.contentSize.width,self.contentSize.height), ccc4f(0.62, 0.32, 0.175, 1.0));
}

@end
