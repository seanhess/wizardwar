//
//  SpellFireball.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellFail.h"
#import "SpellWall.h"

@implementation SpellFail

-(id)init {
    if ((self=[super init])) {
        self.name = @"fail";
        self.damage = 0;
    }
    return self;
}

-(SpellInteraction*)interactSpell:(Spell*)spell {
    if ([spell isKindOfClass:[SpellWall class]] && self.direction == spell.direction) {
        return [SpellInteraction nothing];
    }
    
    return [SpellInteraction cancel];
}

@end
