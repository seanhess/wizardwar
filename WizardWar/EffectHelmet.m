//
//  EffectHelmet.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "EffectHelmet.h"
#import "SpellFist.h"

@implementation EffectHelmet

-(SpellInteraction*)interactPlayer:(Player*)player spell:(Spell*)spell {
    if ([spell isType:[SpellFist class]]) {
        return [SpellInteraction nothing];
    }
    else {
        return [super interactPlayer:player spell:spell];
    }
}

@end
