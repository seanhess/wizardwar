//
//  SpellInvisibility.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellInvisibility.h"
#import "EffectInvisible.h"

@implementation SpellInvisibility

-(id)init {
    if ((self=[super init])) {
        self.speed = 0;
        self.damage = 0;
    }
    return self;
}

-(Effect*)effect {
    Effect * effect = [EffectInvisible new];
    effect.active = NO;
    effect.delay = 1.0;
    
    // now wait for a bit
    double delayInSeconds = effect.delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        effect.active = YES;
    });
    
    return effect;
}

-(SpellInteraction *)interactSpell:(Spell *)spell {
    return [SpellInteraction nothing];
}


@end
