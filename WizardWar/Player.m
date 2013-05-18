//
//  Player.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Player.h"
#import "Spell.h"
#import "SpellFireball.h"

@interface Player ()
@property (nonatomic) NSTimeInterval stateAnimationTime;
@end

@implementation Player

-(id)init {
    if ((self=[super init])) {
        self.mana = 0;
        self.health = 5;
    }
    return self;
}

-(NSDictionary*)toObject {
    return [self dictionaryWithValuesForKeys:@[@"name", @"position", @"mana", @"health"]];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@ %@ - %f", super.description, self.name, self.position];
}

-(BOOL)isFirstPlayer {
    return self.position == UNITS_MIN;
}

-(void)setState:(PlayerState)state animated:(BOOL)animated {
    // can't change if dead!
    if (self.state == PlayerStateDead) return;
    self.state = state;
    if (animated) {
        if (state == PlayerStateHit)
            self.stateAnimationTime = 0.5;
        else if (state == PlayerStateCast)
            self.stateAnimationTime = 1.0;
    }
    else
        self.stateAnimationTime = 0.0;
    [self.delegate didUpdateForRender];
}

-(void)update:(NSTimeInterval)dt {
    if (self.stateAnimationTime > 0) {
        self.stateAnimationTime -= dt;
        if (self.stateAnimationTime <= 0) {
            self.state = PlayerStateReady;
            [self.delegate didUpdateForRender];
        }
    }
    
    float newMana = self.mana + dt / 2.0;
    
    if (floor(self.mana - .05) != floor(newMana)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HealthManaUpdate" object:nil];
    }
    
    self.mana = newMana;
    
    if (self.mana > self.health) {
        self.mana = self.health;
    } else if (self.mana < 0) {
        self.mana = 0;
    }
}

@end
