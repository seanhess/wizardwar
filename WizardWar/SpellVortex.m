//
//  SpellVortex.m
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellVortex.h"

#define TICKS_PER_STRENGTH_LOSS 10

@implementation SpellVortex

-(id)init {
    if ((self = [super init])) {
        self.strength = 1;
        self.name = @"Vortex";        
    }
    return self;
}

// if it hits a spell it gets bigger
// does it get slower too?
// it sort of picks a spot. So you have to ignore it.

// vortex kills ALL spells
// but you can't use it defensively or it hits YOU

-(SpellInteraction*)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    if ((currentTick - self.createdTick) % TICKS_PER_STRENGTH_LOSS == 0) {
        self.strength = 0;
        
        // hmm, I can't send back the details here :(
        // needs to be able to interact
        // or send back an interaction or something
    }
    return nil;
}

-(SpellInteraction*)interactSpell:(Spell*)spell currentTick:(NSInteger)currentTick {
    
    if (self.strength > 0) {
        self.strength += 1;
        self.speed /= 10;
        if (self.speed < 0) self.speed = 0;
    }
    
    return [SpellInteraction nothing];
}

@end
