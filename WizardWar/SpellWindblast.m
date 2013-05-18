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

@implementation SpellWindblast

-(id)init {
    if ((self=[super init])) {
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
        [self reflectFromSpell:spell];
        return [SpellInteraction modify];
    }
    
    return [SpellInteraction nothing];
}

@end
