//
//  SpellFireball.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellFireball.h"
#import "SpellEarthwall.h"

@implementation SpellFireball

-(id)init {
    if ((self=[super init])) {
        self.speed = 40;
    }
    return self;
}

-(SpellInteraction*)interactSpell:(Spell*)spell {
    
    if ([spell isType:[SpellEarthwall class]]) {
        return [SpellInteraction cancel];
    }
    
    // fire + fire is ignored
    
    return [SpellInteraction nothing];
}

@end
