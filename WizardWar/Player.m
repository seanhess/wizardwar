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

#define SECONDS_PER_MANA 1.5

@interface Player ()
@property (nonatomic) NSTimeInterval stateAnimationTime;
@property (nonatomic) float dMana;
@end

@implementation Player

-(id)init {
    if ((self=[super init])) {
        self.mana = 0;
        self.health = 5;
        self.wizardType = WIZARD_TYPE_ONE;
    }
    return self;
}

-(NSDictionary*)toObject {
    return [self dictionaryWithValuesForKeys:@[@"name", @"position", @"mana", @"health", @"state"]];
}

-(void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues {
    PlayerState currentState = self.state;
    [super setValuesForKeysWithDictionary:keyedValues];
    if (currentState != self.state) {
        [self setState:self.state animated:YES];
    }
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
        else
            self.stateAnimationTime = 0.0;
    }
    else
        self.stateAnimationTime = 0.0;
}

-(void)spendMana:(NSInteger)mana {
    // spends the mana and restarts the clock
    self.dMana = 0.0;
    self.mana -= mana;
}

-(void)update:(NSTimeInterval)dt {

    // destroy the timer if set to dead
    if (self.state == PlayerStateDead)
        self.stateAnimationTime = 0;
    
    if (self.stateAnimationTime > 0) {
        self.stateAnimationTime -= dt;
        if (self.stateAnimationTime <= 0) {
            self.state = PlayerStateReady;
        }
    }
    
    self.dMana += dt / SECONDS_PER_MANA;
    
    if (self.dMana >= 1.0) {
        self.dMana -= 1;
        self.mana += 1;
        
        if (self.mana > self.health) {
            self.mana = self.health;
        } else if (self.mana < 0) {
            self.mana = 0;
        }
    }
}

+(NSString*)randomWizardType {
    NSArray * types = @[WIZARD_TYPE_ONE, WIZARD_TYPE_TWO];
    NSUInteger randomIndex = arc4random() % types.count;
    return types[randomIndex];
}

@end
