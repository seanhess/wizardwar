//
//  SpellInvisibility.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellInvisibility.h"
#import "EffectInvisible.h"

@implementation SpellInvisibility

-(id)init {
    if ((self=[super init])) {
        self.speed = 0;
        self.damage = 0;
    }
    return self;
}

-(Effect*)effect {
    Effect * effect = [EffectInvisible new];
    [effect start];
    return effect;
}

-(SpellInteraction *)interactSpell:(Spell *)spell {
    return [SpellInteraction nothing];
}


@end
