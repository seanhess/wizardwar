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
        self.speed = 50;
        self.damage = 0;
        self.heavy = NO;
        self.name = @"Wind Blast";
        self.castDelay = 0.3;
    }
    return self;
}

-(SpellInteraction*)interactWizard:(Wizard *)wizard currentTick:(NSInteger)currentTick {
    return [SpellInteraction nothing];
}

-(SpellInteraction *)interactSpell:(Spell *)spell currentTick:(NSInteger)currentTick {
//    if ([spell isType:[SpellMonster class]]) {
//        return [SpellInteraction cancel];
//    }
    
//    else if ([spell isType:[SpellFireball class]]) {
//        return [SpellInteraction cancel];
//    }
    
    if ([spell isType:[SpellEarthwall class]] && spell.direction != self.direction) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellIcewall class]] && spell.direction != self.direction) {
        self.direction *= -1;
        return [SpellInteraction modify];
    }
    
    return [SpellInteraction nothing];
}

@end
