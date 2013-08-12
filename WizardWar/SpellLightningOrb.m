//
//  SpellLightningOrb.m
//  WizardWar
//
//  Created by Sean Hess on 8/12/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellLightningOrb.h"
#import "SpellEarthwall.h"
#import "SpellWindblast.h"
#import "SpellIcewall.h"
#import "SpellBubble.h"
#import "SpellMonster.h"
#import "SpellFireball.h"
#import "SpellFirewall.h"

@implementation SpellLightningOrb

-(id)init {
    if ((self=[super init])) {
        self.heavy = NO;
        self.name = @"Lightning Orb";
    }
    return self;
}

-(SpellInteraction*)interactSpell:(Spell*)spell currentTick:(NSInteger)currentTick {
    
    if ([spell isType:[SpellIcewall class]] && spell.direction != self.direction) {
        return [SpellInteraction cancel];
    }
    
//    if ([spell isType:[SpellFirewall class]] && spell.direction != self.direction) {
//        self.damage += 1;        
//        return [SpellInteraction modify];
//    }    
    
    if ([spell isType:[SpellMonster class]]) {
        return [SpellInteraction cancel];
    }
    
    // Try this for now! Might be OP
    if ([spell isType:[SpellFireball class]]) {
        self.damage += 1;
        return [SpellInteraction modify];
    }
    
    return [SpellInteraction nothing];
}




@end
