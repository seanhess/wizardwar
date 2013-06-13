//
//  SpellSleep.m
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellSleep.h"
#import "SpellMonster.h"
#import "EffectSleep.h"

@implementation SpellSleep

-(id)init {
    if ((self=[super init])) {
        self.damage = 0;
    }
    return self;
}

-(Effect*)effect {
    return [EffectSleep new];
}

-(SpellInteraction *)interactSpell:(Spell *)spell {
    
    if ([spell isType:[SpellMonster class]]) {
        return [SpellInteraction cancel];
    }
        
    return [SpellInteraction nothing];
}

@end
