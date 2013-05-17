//
//  SpellEarthwall.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellEarthwall.h"

@implementation SpellEarthwall

-(id)init {
    if ((self=[super init])) {
        self.speed = 0;
        self.size = 40;
    }
    return self;
}

-(SpellInteraction*)interactSpell:(Spell*)spell {
    return [SpellInteraction nothing];
}

@end
