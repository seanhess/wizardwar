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
#import "SpellLightningOrb.h"

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


-(SpellInteraction*)interactSpell:(Spell*)spell currentTick:(NSInteger)currentTick {
    
    if ([spell isType:[SpellEarthwall class]] && spell.direction != self.direction) {
        // DO NOT: reduce the strength of the fireball too
        // the earthwall is reducing its strength, and it's not clear which happens first
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellWindblast class]]) {
        // all it does is make it bigger
        // tee hee
        self.damage += 1;
        return [SpellInteraction modify];
    }
    
    else if ([spell isType:[SpellIcewall class]] && spell.direction != self.direction) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellLightningOrb class]]) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellBubble class]]) {
        if (self.position == spell.position && self.speed == spell.speed && self.direction == spell.direction)
            return [SpellInteraction nothing];
        
        self.linkedSpell = spell;
        self.position = spell.position;
        self.speed = spell.speed;
        self.direction = spell.direction;
        return [SpellInteraction modify];
    }
    
//    else if ([spell isType:[SpellMonster class]]) {
//        self.damage -= 1;
//        if (self.damage > 0) {
//            return [SpellInteraction modify];
//        } else {
//            return [SpellInteraction cancel];
//        }
//    }
    
    // fire + fire is ignored
    return [SpellInteraction nothing];
}

@end
