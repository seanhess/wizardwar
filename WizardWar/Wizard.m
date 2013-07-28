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
#define CAST_STATUS_DURATION 0.5
#define HIT_STATUS_DURATION 1.0

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
    [super setValuesForKeysWithDictionary:keyedValues];
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

-(void)setStatus:(WizardStatus)status atTick:(NSInteger)tick {    
    // can't change if dead or won! It is forever
    if (self.state == WizardStatusDead || self.state == WizardStatusWon) return;
    
    self.state = status;
    self.updatedTick = tick;
}

- (void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    [self.effect simulateTick:currentTick interval:interval player:self];
    
    if (self.state == WizardStatusCast || self.state == WizardStatusHit) {
        NSInteger elapsedTicks = (currentTick - self.updatedTick);
        NSTimeInterval elapsedTime = elapsedTicks * interval;
        
        if ((self.state == WizardStatusCast && elapsedTime >= CAST_STATUS_DURATION) || (self.state == WizardStatusHit && elapsedTime >= HIT_STATUS_DURATION)) {
            self.state = WizardStatusReady;
        }
    }
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
