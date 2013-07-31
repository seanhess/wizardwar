//
//  SpellFireball.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellFireball.h"
#import "SpellEarthwall.h"
#import "SpellWindblast.h"
#import "SpellIcewall.h"
#import "SpellBubble.h"
#import "SpellMonster.h"

@implementation SpellFireball

-(id)init {
    if ((self=[super init])) {
//        self.speed = 40; // make it slower so you can do the windblast combo
//        self.speed = 25;
        self.heavy = NO;
        self.name = @"Fireball";
    }
    return self;
}


-(SpellInteraction*)interactSpell:(Spell*)spell {
    
    if ([spell isType:[SpellEarthwall class]]) {
        // TODO wear down!
        // oh, yeah! wear it down for sure!
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellWindblast class]]) {
        // TODO make it bigger
        
        // if going the same direction, then make it bigger and faster?
        // if not, then dissipate it
        // only make it bigger!
        if (self.direction == spell.direction) {
            self.damage += 1;
            self.speed += 5;
        } else {
            self.damage -= 1;
        }
        
        if (self.damage > 0) {
            return [SpellInteraction modify];
        } else {
            return [SpellInteraction cancel];
        }
    }
    
    else if ([spell isType:[SpellIcewall class]]) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellBubble class]]) {
        if (self.position == spell.position && self.speed == spell.speed && self.direction == spell.direction)
            return [SpellInteraction nothing];
        
        self.position = spell.position;
        self.speed = spell.speed;
        self.direction = spell.direction;
        return [SpellInteraction modify];
    }
    
    else if ([spell isType:[SpellMonster class]]) {
        self.damage -= 1;
        
        if (self.damage > 0) {
            return [SpellInteraction modify];
        } else {
            return [SpellInteraction cancel];
        }
    }
    
    
    // fire + fire is ignored
    return [SpellInteraction nothing];
}

@end
