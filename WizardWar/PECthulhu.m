//
//  PECthulhu.m
//  WizardWar
//
//  Created by Sean Hess on 8/22/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "PECthulhu.h"
#import "Wizard.h"
#import "Spell.h"

#define RAISE_SPEED 1.0

@implementation PECthulhu

-(id)init {
    if ((self = [super init])) {
    }
    return self;
}

-(BOOL)interceptSpell:(Spell *)spell onWizard:(Wizard *)wizard interval:(NSTimeInterval)interval currentTick:(NSInteger)currentTick {
    return YES;
}

-(BOOL)applySpell:(Spell *)spell onWizard:(Wizard *)wizard currentTick:(NSInteger)currentTick {
    [super applySpell:spell onWizard:wizard currentTick:currentTick];
    spell.strength = 666;
    spell.speedY = RAISE_SPEED;
    return NO;
}

// wahoo... here he comes
-(BOOL)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval player:(Wizard*)wizard {
    wizard.altitude += RAISE_SPEED * interval;
    
    if (wizard.altitude >= 3.0) {
        wizard.health = 0;
        return YES;
    }
    
    return NO;
}


@end
