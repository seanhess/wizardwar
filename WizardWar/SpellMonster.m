//
//  SpellMonster.m
//  WizardWar
//
//  Created by Sean Hess on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//


#import "SpellIcewall.h"
#import "SpellFireball.h"
#import "SpellEarthwall.h"
#import "SpellMonster.h"
#import "SpellBubble.h"
#import "SpellVine.h"
#import "SpellWindblast.h"
#import "SpellFirewall.h"
#import "SpellSleep.h"

@implementation SpellMonster

-(id)init {
    if ((self=[super init])) {
        self.speed = 20;
        self.name = @"Summon Ogre";
        self.castDelay *= 1.5;
    }
    return self;
}

-(SpellInteraction *)interactSpell:(Spell *)spell {
    if ([spell isType:[SpellMonster class]]) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellFireball class]]) {
        return [SpellInteraction cancel];
    }
    
//    else if ([spell isType:[SpellBubble class]]) {
//        self.direction = spell.direction;
//        return [SpellInteraction modify];
//    }
    
    else if ([spell isType:[SpellFirewall class]] && self.direction != spell.direction) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellEarthwall class]] && self.direction != spell.direction) {
        self.speed = 5;
        return [SpellInteraction modify];
    }
    
    else if ([spell isType:[SpellSleep class]]) {
        self.speed = 0;
        self.effect = spell.effect;
        return [SpellInteraction modify];
    }
    
    else if ([spell isType:[SpellWindblast class]]) {
        if (self.direction == spell.direction) {
            self.speed += 30;
        }
        else {
            self.speed -= 15;
            if (self.speed < 0) {
                self.direction *= -1;
                self.speed *= -1;
            }
        }
        
            
        return [SpellInteraction modify];
    }
    
    return [SpellInteraction nothing];
}

@end
