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
#import "EffectSleep.h"
#import "EffectBasicDamage.h"

@implementation SpellMonster

-(id)init {
    if ((self=[super init])) {
        self.speed = 20;
        self.name = @"Summon Ogre";
        self.castDelay *= 1.5;
    }
    return self;
}

-(SpellInteraction *)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    
    if ([self.effect isKindOfClass:[EffectSleep class]]) {
        EffectSleep * sleep = (EffectSleep*)self.effect;
        if ([sleep sleepShouldEndAtTick:currentTick interval:interval]) {
            self.effect = [EffectBasicDamage new];
            self.speed = 20;
            return [SpellInteraction modify];
        }
    }
    
    return [super simulateTick:currentTick interval:interval];
}

-(SpellInteraction *)interactSpell:(Spell *)spell currentTick:(NSInteger)currentTick {
    if ([spell isType:[SpellMonster class]]) {
        if(spell.direction != self.direction)
            return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellFireball class]]) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isKindOfClass:[SpellFailHotdog class]]) {
        self.damage += 1;
        return [SpellInteraction modify];
    }
    
//    else if ([spell isType:[SpellBubble class]]) {
//        self.direction = spell.direction;
//        return [SpellInteraction modify];
//    }
    
    else if ([spell isType:[SpellFirewall class]] && self.direction != spell.direction) {
        return [SpellInteraction cancel];
    }
    
    else if ([spell isType:[SpellEarthwall class]] && self.direction != spell.direction) {
        self.speed = 5;
        return [SpellInteraction modify];
    }
    
    else if ([spell isType:[SpellSleep class]]) {
        self.speed = 0;
        self.effect = spell.effect;
        [self.effect start:currentTick player:nil];
        // TODO this does not propogate!!!
        return [SpellInteraction modify];
    }
    
    else if ([spell isType:[SpellWindblast class]]) {
        if ([self.effect isKindOfClass:[EffectSleep class]]) {
            return [SpellInteraction nothing];
        }
        if (self.direction == spell.direction) {
            self.speed += 30;
        }
        else {
            self.speed -= 15;
            if (self.speed < 0) {
                self.direction *= -1;
                self.speed *= -1;
            }
        }
        
            
        return [SpellInteraction modify];
    }
    
    return [SpellInteraction nothing];
}

@end
