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
        self.delay = 2.0;
        self.cancelsOnCast = YES;
    }
    return self;
}

-(void)start {
    self.active = NO;
}

-(SpellInteraction*)interactPlayer:(Wizard*)player spell:(Spell*)spell currentTick:(NSInteger)currentTick {
    if (self.active && ![spell isType:[SpellFist class]]) {
        return [SpellInteraction nothing];
    }
    else {
        return [super interactPlayer:player spell:spell currentTick:currentTick];
    }
}

-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval player:(Wizard*)player {
    NSInteger ticksPerInvis = round(self.delay / interval);
    NSInteger elapsedTicks = (currentTick - self.startTick);
    
    if (elapsedTicks == ticksPerInvis) {
        NSLog(@"OK OK OK DAWG");        
        self.active = YES;
    }
}

@end
