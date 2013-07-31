//
//  SpellEarthwall.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellFirewall.h"
#import "SpellFireball.h"
#import "SpellMonster.h"
#import "SpellIcewall.h"
#import "SpellBubble.h"
#import "Tick.h"

@implementation SpellFirewall

-(id)init {
    if ((self=[super init])) {
        self.strength = 3;
        self.name = @"Wall of Fire";
        self.speed = 10;
    }
    return self;
}


-(SpellInteraction *)interactSpell:(Spell *)spell {
    
    // replace older walls
    if ([self isNewerWall:spell]) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellBubble class]]) {
        // do whatever fireball does
        if (self.position == spell.position && self.speed == spell.speed && self.direction == spell.direction)
            return [SpellInteraction nothing];
                
        self.position = spell.position;
        self.speed = spell.speed;
        self.direction = spell.direction;
        return [SpellInteraction modify];
    }
    
    return [SpellInteraction nothing];
}

@end
