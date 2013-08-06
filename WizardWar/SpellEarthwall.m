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
#import "SpellFirewall.h"
#import "Tick.h"

@implementation SpellEarthwall

-(id)init {
    if ((self=[super init])) {
        self.strength = 3;
        self.name = @"Wall of Earth";
    }
    return self;
}

-(SpellInteraction *)interactSpell:(Spell *)spell {
    
    // Earthwalls and Firewalls can collide if the firewall is contained by a bubble.
    if ([spell isKindOfClass:[SpellFirewall class]] && spell.direction != self.direction) {
        return [SpellInteraction cancel];
    }
    
    
    // replace older walls
    else if ([self isNewerWall:spell]) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellFireball class]] && spell.direction != self.direction) {
        self.strength -= spell.damage;
        
        if (self.strength <= 0)
            return [SpellInteraction cancel];
        else
            return [SpellInteraction modify];
    }
    
    else if ([spell isType:[SpellMonster class]] && spell.direction != self.direction) {
        return [SpellInteraction cancel];
    }
    
    return [SpellInteraction nothing];
}

@end
