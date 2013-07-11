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

// Hmm, intercept needs to be able to allow it to pass through!
-(SpellInteraction *)interceptSpell:(Spell *)spell onWizard:(Wizard *)wizard {
    // make everything pass through me except for fist
    if ([spell isType:[SpellFist class]]) {
        wizard.effect = nil;                // the helmet is broken!
        return [SpellInteraction cancel];
    }
    else {
        return nil;
    }
}

@end
