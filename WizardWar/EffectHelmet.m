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

// effects need to be able to cancel the spells themselves!
-(SpellInteraction*)interactPlayer:(Player*)player spell:(Spell*)spell {
    if ([spell isType:[SpellFist class]]) {
        return [SpellInteraction cancel];
    }
    else {
        return [super interactPlayer:player spell:spell];
    }
}

@end
