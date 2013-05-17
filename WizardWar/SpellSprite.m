//
//  SpellSprite.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellSprite.h"
#import "cocos2d.h"

#define PIXELS_PER_UNIT 10
#define GROUND_LEVEL 100

@implementation SpellSprite

-(id)initWithSpell:(Spell*)spell {
    if ((self=[super init])) {
        self.spell = spell;
        spell.delegate = self;
    }
    return self;
}

-(void)draw {
    ccDrawSolidRect(ccp(0, 0), ccp(self.spell.size, 40), ccc4f(0, 1, 0, 1));
}

-(void)didUpdateForRender {
    self.position = ccp(self.spell.position * PIXELS_PER_UNIT, GROUND_LEVEL);
}

@end
