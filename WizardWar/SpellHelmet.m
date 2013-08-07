//
//  SpellFist.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellHelmet.h"
#import "EffectHelmet.h"

@implementation SpellHelmet

-(id)init {
    if ((self=[super init])) {
        self.speed = 0;
        self.damage = 0;
        self.effect = [EffectHelmet new];
        self.targetSelf = YES;
        self.name = @"Mighty Helmet";
    }
    return self;
}

-(SpellInteraction*)interactSpell:(Spell*)spell currentTick:(NSInteger)currentTick {
    return [SpellInteraction nothing];
}


@end
