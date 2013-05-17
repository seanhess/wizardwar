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

-(NSDictionary*)toObject {
    return [self dictionaryWithValuesForKeys:@[@"name", @"position", @"mana", @"maxMana"]];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@ %@ - %f", super.description, self.name, self.position];
}

-(BOOL)isFirstPlayer {
    return self.position == UNITS_MIN;
}

-(void)interactSpell:(Spell*)spell {
    // switch based on spell type
    if ([spell isType:[SpellFireball class]]) {
        NSLog(@"FIREBALL HIT");
    }
    
    else {
        NSLog(@"NO COMPRENDO");
    }
}

@end
