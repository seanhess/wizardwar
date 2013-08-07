//
//  SpellFailTeddy.m
//  WizardWar
//
//  Created by Sean Hess on 8/1/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellFailTeddy.h"
#import "EffectTeddyHeal.h"

@implementation SpellFailTeddy

-(id)init {
    if ((self=[super init])) {
        self.name = @"Teddy Bear";
    }
    return self;
}

-(Effect*)effect {
    return [EffectTeddyHeal new];
}

// It goes through EVERYTHING to heal your opponent
-(SpellInteraction*)interactSpell:(Spell*)spell currentTick:(NSInteger)currentTick {
    return [SpellInteraction nothing];
}

@end
