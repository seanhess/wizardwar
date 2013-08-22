//
//  SpellMonster.m
//  WizardWar
//
//  Created by Sean Hess on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//


#import "SpellMonster.h"
#import "PESleep.h"
#import "PEBasicDamage.h"
#import "SpellEffect.h"

@implementation SpellMonster

-(id)initWithInfo:(SpellInfo *)info {
    if ((self=[super initWithInfo:info])) {
        self.speed = 20;
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
