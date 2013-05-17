//
//  SpellFireball.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellFireball.h"

@implementation SpellFireball

-(id)init {
    if ((self=[super init])) {
        self.speed = 40;
    }
    return self;
}

-(SpellInteraction*)interactSpell:(Spell*)spell {
    return [SpellInteraction nothing];
}

@end
