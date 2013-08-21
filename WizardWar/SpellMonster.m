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

@implementation SpellMonster

-(id)init {
    if ((self=[super init])) {
        self.speed = 20;
        self.name = @"Summon Ogre";
        self.castDelay *= 1.8;
    }
    return self;
}

//-(SpellInteraction *)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
//    
////    if (self.effect && [self.effect isKindOfClass:[EffectSleep class]]) {
////        EffectSleep * sleep = (EffectSleep*)self.effect;
////        if ([sleep sleepShouldEndAtTick:currentTick interval:interval]) {
////            self.effect = [EffectBasicDamage new];
////            self.speed = 20;
////            return [SpellInteraction modify];
////        }
////    }
////    
////    return [super simulateTick:currentTick interval:interval];
//    return nil;
//}

@end
