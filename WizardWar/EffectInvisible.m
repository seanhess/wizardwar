//
//  EffectInvisible.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "EffectInvisible.h"

@implementation EffectInvisible

-(SpellInteraction*)interactPlayer:(Player*)player spell:(Spell*)spell {
    if (self.active) {
        return [SpellInteraction nothing];
    }
    else {
        return [super interactPlayer:player spell:spell];
    }
}

@end
