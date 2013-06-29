//
//  SpellWindblast.m
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
#import "Tick.h"

// Windblast just slows things down, etc

@implementation SpellWindblast

-(id)init {
    if ((self=[super init])) {
        self.speed = 100;
        self.damage = 0;
        self.heavy = NO;
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
    
    else if ([spell isType:[SpellEarthwall class]]) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellIcewall class]]) {
        self.direction *= -1;
        return [SpellInteraction modify];
    }
    
    return [SpellInteraction nothing];
}

@end
