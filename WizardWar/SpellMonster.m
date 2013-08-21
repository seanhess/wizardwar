//
//  SpellMonster.m
//  WizardWar
//
//  Created by Sean Hess on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//


#import "SpellIcewall.h"
#import "SpellFireball.h"
#import "SpellEarthwall.h"
#import "SpellMonster.h"
#import "SpellBubble.h"
#import "SpellVine.h"
#import "SpellWindblast.h"
#import "SpellFirewall.h"
#import "SpellSleep.h"
#import "SpellFailHotdog.h"
#import "PESleep.h"
#import "PEBasicDamage.h"
#import "SpellEffect.h"

@implementation SpellMonster

-(id)init {
    if ((self=[super init])) {
        self.speed = 20;
        self.name = @"Summon Ogre";
        self.castDelay *= 1.8;
    }
    return self;
}

-(BOOL)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    
    if (self.spellEffect && [self.spellEffect isKindOfClass:[SESleep class]]) {
        if ([PESleep sleepShouldEndAtTick:currentTick interval:interval started:self.updatedTick]) {
            self.spellEffect = nil;
            self.speed = 20;
            return YES;
        }
    }
    
    return [super simulateTick:currentTick interval:interval];
}

@end
