//
//  EffectInvisible.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "PEInvisible.h"
#import "Spell.h"
#import "SpellFist.h"
#import "SpellEffectService.h"

@implementation PEInvisible

-(id)init {
    self = [super init];
    if (self) {
        self.delay = 2.0;
        self.cancelsOnCast = YES;
        self.description = @"Turns the player invisible";
    }
    return self;
}

// Hmm, intercept needs to be able to allow it to pass through!
-(BOOL)interceptSpell:(Spell *)spell onWizard:(Wizard *)wizard interval:(NSTimeInterval)interval currentTick:(NSInteger)currentTick {
    // make everything pass through me except for fist
    // Umm, this doesn't make it pass through, it makes it hit me :(
    if ([self isActive:wizard interval:interval tick:currentTick] && ![spell.type isEqualToString:Fist]) {
        NSLog(@"IS ACTIVE %@ %i %i", wizard, currentTick, wizard.effectStartTick);
        return YES;
    }
    else {
        return NO;
    }
}

-(BOOL)isActive:(Wizard*)wizard interval:(NSTimeInterval)interval tick:(NSInteger)tick {
    NSInteger ticksPerInvis = round(self.delay / interval);
    NSInteger elapsedTicks = (tick - wizard.effectStartTick);
    return (elapsedTicks >= ticksPerInvis);
}

@end
