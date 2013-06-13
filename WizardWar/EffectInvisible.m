//
//  EffectInvisible.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "EffectInvisible.h"
#import "Spell.h"
#import "SpellFist.h"

@implementation EffectInvisible

-(id)init {
    self = [super init];
    if (self) {
        self.active = NO;
        self.delay = 1.0;
        self.cancelsOnCast = YES;
    }
    return self;
}

-(void)start {
    // now wait for a bit
    double delayInSeconds = self.delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.active = YES;
    });
}

-(SpellInteraction*)interactPlayer:(Player*)player spell:(Spell*)spell currentTick:(NSInteger)currentTick {
    if (self.active && ![spell isType:[SpellFist class]]) {
        return [SpellInteraction nothing];
    }
    else {
        return [super interactPlayer:player spell:spell currentTick:currentTick];
    }
}

@end
