//
//  SpellFireball.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellFail.h"

@implementation SpellFail

-(id)init {
    if ((self=[super init])) {
        self.name = @"fail";
        self.damage = 0;
    }
    return self;
}

-(SpellInteraction*)interactSpell:(Spell*)spell {
    // don't do much of anything
    return [SpellInteraction nothing];
}

-(SpellInteraction*)interactWizard:(Wizard *)wizard currentTick:(NSInteger)currentTick {
    return [SpellInteraction nothing];
}

@end
