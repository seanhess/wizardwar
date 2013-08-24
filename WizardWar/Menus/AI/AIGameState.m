//
//  AIGameState.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AIGameState.h"
#import "NSArray+Functional.h"

@implementation AIGameState

-(NSTimeInterval)timeSinceLastCast {
    return (self.currentTick - self.lastSpellCast.createdTick) * self.interval;
}

-(BOOL)isCooldown {
    return (self.lastSpellCast && self.timeSinceLastCast < self.lastTimeRequired);
}

-(NSArray*)mySpells {
    return [self.spells filter:^BOOL(Spell*spell) {
        return (spell.creator == self.wizard);
    }];
}

-(Spell *)activeWall {
    return [self.mySpells find:^BOOL(Spell*spell) {
        return spell.isWall;
    }];
}


@end
