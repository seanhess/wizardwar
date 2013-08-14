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
#import "SpellEarthwall.h"
#import "Tick.h"

@implementation SpellFirewall

-(id)init {
    if ((self=[super init])) {
        self.damage = 1;
        self.strength = 3;
        self.name = @"Wall of Fire";
    }
    return self;
}


-(SpellInteraction *)interactSpell:(Spell *)spell currentTick:(NSInteger)currentTick {
    
    // Earthwalls and Firewalls can collide if the firewall is contained by a bubble.
    if ([spell isKindOfClass:[SpellEarthwall class]] && spell.direction != self.direction) {
        return [SpellInteraction cancel];
    }
    
    // replace older walls
    else if ([self isNewerWall:spell]) {
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
    
    // You CAN'T do the spell strength thing!
    // Firewall has an animation, so you would need each size animated (unless you made it smaller)
    // Actually that would work pretty well
    else if ([spell isKindOfClass:[SpellMonster class]] && spell.direction != self.direction) {
        self.strength -= spell.damage;
        
        if (self.strength <= 0)
            return [SpellInteraction cancel];
        else
            return [SpellInteraction modify];
    }
    
    return [SpellInteraction nothing];
}

@end
