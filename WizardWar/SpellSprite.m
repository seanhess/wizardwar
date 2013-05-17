//
//  SpellSprite.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellSprite.h"
#import "cocos2d.h"

@implementation SpellSprite

-(void)draw {
    ccDrawSolidRect(ccp(0, 0), ccp(self.spell.size, 40), ccc4f(0, 1, 0, 1));
}

@end
