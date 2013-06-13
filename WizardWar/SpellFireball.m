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
        self.speed = 40;
        self.heavy = NO;
    }
    return self;
}


-(SpellInteraction*)interactSpell:(Spell*)spell {
    
    if ([spell isType:[SpellEarthwall class]]) {
        // TODO wear down!
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellWindblast class]]) {
        // TODO make it bigger
        self.damage += 1;
        return [SpellInteraction modify];
    }
    
    else if ([spell isType:[SpellIcewall class]]) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellBubble class]]) {
        self.position = spell.position;
        self.speed = spell.speed;
        self.direction = spell.direction;
        return [SpellInteraction modify];
    }
    
    else if ([spell isType:[SpellMonster class]]) {
        return [SpellInteraction cancel];
    }
    
    
    // fire + fire is ignored
    return [SpellInteraction nothing];
}

@end
