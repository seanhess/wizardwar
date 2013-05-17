//
//  SpellEarthwall.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellEarthwall.h"
#import "SpellFireball.h"

@implementation SpellEarthwall

-(id)init {
    if ((self=[super init])) {
        self.speed = 0;
    }
    return self;
}

-(SpellInteraction *)interactSpell:(Spell *)spell {
    
    if ([spell isType:[SpellEarthwall class]]) {
        return [SpellInteraction cancel];
    }
    
    if ([spell isType:[SpellFireball class]]) {
        return [SpellInteraction cancel];
    }
    
    return [SpellInteraction nothing];
}

@end
