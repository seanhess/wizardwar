//
//  EffectHeal.m
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "PEHeal.h"
#import "Wizard.h"



@implementation PEHeal

-(id)init {
    self = [super init];
    if (self) {
        self.cancelsOnCast = YES;
        self.cancelsOnHit = YES;
    }
    return self;
}

+(id)delay:(NSTimeInterval)delay {
    PEHeal * heal = [PEHeal new];
    heal.delay = delay;
    return heal;
}

// ok, so I need to check to see if they've waited long enough to heal
// it can only heal ONE heart
// if you get hit in the meantime it doesn't work
-(BOOL)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval player:(Wizard*)wizard {
    NSInteger ticksPerHeal = round(self.delay / interval);
    NSInteger elapsedTicks = (currentTick - wizard.effectStartTick);
    
    if (elapsedTicks >= ticksPerHeal) {
        wizard.effect = nil;
        wizard.health += 1;
        
        if (wizard.health > MAX_HEALTH)
            wizard.health = MAX_HEALTH;
        
        return YES;
    }
    return NO;
}

@end
