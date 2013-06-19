//
//  EffectSleep.m
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "EffectSleep.h"
#import "Spell.h"

#define EFFECT_SLEEP_DURATION 5

@implementation EffectSleep

-(id)init {
    self = [super init];
    if (self) {
        self.disablesPlayer = YES;
    }
    return self;
}

-(SpellInteraction*)interactSpell:(Spell *)spell {
    spell.speed = 0;
    spell.effect = self;
    return [SpellInteraction modify];
}

// the default effect is to damage the player and cancel the spell
-(SpellInteraction*)interactPlayer:(Wizard*)player spell:(Spell*)spell currentTick:(NSInteger)currentTick {
    player.effect = self;
    [player.effect start:currentTick player:player];
    return [SpellInteraction cancel];
}

-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval player:(Wizard *)player {
    NSInteger ticksPerDuration = round(EFFECT_SLEEP_DURATION / interval);
    if ((currentTick - self.startTick) >= ticksPerDuration) {
        player.effect = nil;
    }
}

@end
