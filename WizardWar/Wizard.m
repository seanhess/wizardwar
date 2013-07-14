//
//  Player.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Wizard.h"
#import "Spell.h"
#import "SpellFireball.h"
#import "UIColor+Hex.h"

#define SECONDS_PER_MANA 1.5

@interface Wizard ()
@property (nonatomic) NSTimeInterval stateAnimationTime;
@end

@implementation Wizard

-(id)init {
    if ((self=[super init])) {
        self.health = MAX_HEALTH;
        self.wizardType = WIZARD_TYPE_ONE;
    }
    return self;
}

-(NSDictionary*)toObject {
    return [self dictionaryWithValuesForKeys:@[@"name", @"position", @"health", @"state", @"colorRGB"]];
}

-(void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues {
    WizardStatus currentState = self.state;
    [super setValuesForKeysWithDictionary:keyedValues];
    if (currentState != self.state) {
        [self setState:self.state animated:YES];
    }
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@ %@ - %f", super.description, self.name, self.position];
}

- (void)setHealth:(NSInteger)health {
    if (health > MAX_HEALTH) health = MAX_HEALTH;
    else if (health < 0) health = 0;
    
    _health = health;
}

-(BOOL)isFirstPlayer {
    return self.position == UNITS_MIN;
}

-(NSInteger)direction {
    return (self.isFirstPlayer) ? 1 : -1;
}

-(void)setState:(WizardStatus)state animated:(BOOL)animated {
    // can't change if dead!
    if (self.state == WizardStatusDead || self.state == WizardStatusWon) return;
    self.state = state;
    if (animated) {
        if (state == WizardStatusHit)
            self.stateAnimationTime = 0.5;
        else if (state == WizardStatusCast)
            self.stateAnimationTime = 1.0;
        else
            self.stateAnimationTime = 0.0;
    }
    else
        self.stateAnimationTime = 0.0;
}

-(void)update:(NSTimeInterval)dt {

    // destroy the timer if set to dead
    if (self.state == WizardStatusDead || self.state == WizardStatusWon)
        self.stateAnimationTime = 0;
    
    if (self.stateAnimationTime > 0) {
        self.stateAnimationTime -= dt;
        if (self.stateAnimationTime <= 0) {
            if (self.state == WizardStatusDead || self.state == WizardStatusWon) return;
            self.state = WizardStatusReady;
        }
    }
}

- (void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    [self.effect simulateTick:currentTick interval:interval player:self];
}

- (UIColor*)color {
    return [UIColor colorFromRGB:self.colorRGB];
}

- (void)setColor:(UIColor *)color {
    self.colorRGB = color.RGB;
}


+(NSString*)randomWizardType {
    NSArray * types = @[WIZARD_TYPE_ONE, WIZARD_TYPE_TWO];
    NSUInteger randomIndex = arc4random() % types.count;
    return types[randomIndex];
}

@end
