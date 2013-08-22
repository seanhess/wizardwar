//
//  PECthulhu.m
//  WizardWar
//
//  Created by Sean Hess on 8/22/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "PECthulhu.h"
#import "Wizard.h"

@implementation PECthulhu

-(id)init {
    if ((self = [super init])) {
        NSLog(@"CTHULHU! HOORAY!");
        self.delay = 3.0;
    }
    return self;
}

// wahoo... here he comes
-(BOOL)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval player:(Wizard*)wizard {
    NSInteger ticksUntilGrab = round((self.delay/2) / interval);
    NSInteger ticksUntilDead = round((self.delay) / interval);
    NSInteger elapsedTicks = (currentTick - wizard.effectStartTick);
    
    if (elapsedTicks >= ticksUntilDead) {
        wizard.health = 0;
        return YES;
    }
    
    else if (elapsedTicks >= ticksUntilGrab) {
        wizard.altitude = 3;
    }
    return NO;
}


@end
