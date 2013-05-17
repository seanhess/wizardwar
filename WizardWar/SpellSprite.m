//
//  SpellSprite.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellSprite.h"
#import "cocos2d.h"

@interface SpellSprite ()
@property (nonatomic, strong) Units * units;
@end

@implementation SpellSprite


-(id)initWithSpell:(Spell*)spell units:(Units *)units {
    if ((self=[super init])) {
        self.spell = spell;
        self.units = units;
        spell.delegate = self;
    }
    return self;
}

-(void)draw {
    ccDrawSolidRect(ccp(0, 0), ccp(self.spell.size, 40), ccc4f(0, 1, 0, 1));
}

-(void)didUpdateForRender {
    self.position = ccp([self.units pixelsXForUnitPosition:self.spell.position], self.units.groundY);
}

@end
