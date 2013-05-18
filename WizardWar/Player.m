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

@end
