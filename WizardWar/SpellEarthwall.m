//
//  SpellEarthwall.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellEarthwall.h"
#import "SpellFireball.h"
#import "SpellMonster.h"
#import "SpellIcewall.h"
#import "Tick.h"

@implementation SpellEarthwall

-(id)init {
    if ((self=[super init])) {
        self.strength = 3;
    }
    return self;
}

-(SpellInteraction *)interactSpell:(Spell *)spell {
    
    // replace older walls
    if ([self isNewerWall:spell]) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellFireball class]]) {
        // TODO wear down!
        self.strength -= spell.damage;
        
        if (self.strength == 0)
            return [SpellInteraction cancel];
        else
            return [SpellInteraction modify];
    }
    
    else if ([spell isType:[SpellMonster class]]) {
        return [SpellInteraction cancel];
    }
    
    return [SpellInteraction nothing];
}

@end
