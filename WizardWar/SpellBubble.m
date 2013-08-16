//
//  SpellBubble.m
//  WizardWar
//
//  Created by Sean Hess on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellBubble.h"
#import "SpellMonster.h"
#import "SpellFireball.h"
#import "SpellIcewall.h"
#import "SpellVine.h"
#import "SpellWindblast.h"

@implementation SpellBubble

-(id)init {
    if ((self=[super init])) {
        self.damage = 0;
        self.heavy = NO;
        self.speed = 20;
        self.name = @"Bubble";
    }
    return self;
}

-(SpellInteraction *)interactSpell:(Spell *)spell currentTick:(NSInteger)currentTick {
    
    if ([spell isType:[SpellWindblast class]]) {
        if (self.direction == spell.direction) {
            self.speed += 35;
        }
        else {
            self.speed -= 35;
            if (self.speed < 0) {
                self.direction *= -1;
                self.speed *= -1;
            }
        }
        return [SpellInteraction modify];
    }
    
    else if ([spell isType:[SpellIcewall class]] && spell.direction != self.direction) {
        self.direction = spell.direction;
        return [SpellInteraction modify];
    }
    
    else if ([spell isType:[SpellMonster class]]) {
        return [SpellInteraction cancel];
    }
    
    return [SpellInteraction nothing];
}

@end
