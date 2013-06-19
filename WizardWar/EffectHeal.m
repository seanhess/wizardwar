//
//  EffectHeal.m
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "EffectHeal.h"
#import "Wizard.h"



@implementation EffectHeal

-(id)init {
    self = [super init];
    if (self) {
        self.cancelsOnCast = YES;
        self.cancelsOnHit = YES;
    }
    return self;
}

// ok, so I need to check to see if they've waited long enough to heal
// it can only heal ONE heart
// if you get hit in the meantime it doesn't work
-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval player:(Wizard*)player {    
    NSInteger ticksPerHeal = round(EFFECT_HEAL_TIME / interval);
    NSInteger elapsedTicks = (currentTick - self.startTick);
    
    if (elapsedTicks >= ticksPerHeal) {
        player.effect = nil;
        player.health += 1;
    }
}

@end
