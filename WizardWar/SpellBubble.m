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
    }
    return self;
}

-(SpellInteraction *)interactSpell:(Spell *)spell {
    
    if ([spell isType:[SpellWindblast class]]) {
        [self reflectFromSpell:spell];
        return [SpellInteraction modify];
    }
    
    else if ([spell isType:[SpellIcewall class]]) {
        [self reflectFromSpell:spell];
        return [SpellInteraction modify];
    }
    
    else if ([spell isType:[SpellMonster class]]) {
        return [SpellInteraction cancel];
    }
    
    return [SpellInteraction nothing];
}

@end
