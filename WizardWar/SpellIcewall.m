//
//  SpellIcewall.m
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
#import "SpellLightningOrb.h"
#import "Tick.h"

@implementation SpellIcewall

-(id)init {
    if ((self=[super init])) {
        self.name = @"Wall of Ice";
    }
    return self;
}

-(SpellInteraction *)interactSpell:(Spell *)spell currentTick:(NSInteger)currentTick {
    if ([spell isType:[SpellMonster class]] && spell.direction != self.direction) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellFireball class]] && spell.direction != self.direction) {
        return [SpellInteraction cancel];
    }
    
    else if ([self isNewerWall:spell]) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellLightningOrb class]] && spell.direction != self.direction) {
        self.strength -= spell.damage;

        if (self.strength <= 0)
            return [SpellInteraction cancel];
        else
            return [SpellInteraction modify];
    }    
    
    return [SpellInteraction nothing];
}

@end
