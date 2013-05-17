//
//  WizardSprite.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "WizardSprite.h"
#import "cocos2d.h"

@implementation WizardSprite

-(void)draw {
    ccDrawSolidRect(ccp(0, 0), ccp(self.contentSize.width,self.contentSize.height), ccc4f(1, 0, 0, 1));
}

@end
