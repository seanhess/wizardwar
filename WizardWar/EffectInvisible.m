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

// Hmm, intercept needs to be able to allow it to pass through!
-(SpellInteraction *)interceptSpell:(Spell *)spell onWizard:(Wizard *)wizard {
    // make everything pass through me except for fist
    // Umm, this doesn't make it pass through, it makes it hit me :(
    if (self.active && ![spell isType:[SpellFist class]]) {
        return [SpellInteraction nothing];
    }
    else {
        return nil;
    }
}

-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval player:(Wizard*)player {
    NSInteger ticksPerInvis = round(self.delay / interval);
    NSInteger elapsedTicks = (currentTick - self.startTick);
    
    if (elapsedTicks == ticksPerInvis) {
        self.active = YES;
    }
}

@end
