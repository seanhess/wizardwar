//
//  SpellWall.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellWall.h"

@implementation SpellWall

-(id)init {
    if ((self=[super init])) {
        self.speed = 0;
        self.strength = 1;
        self.startOffsetPosition = SPELL_WALL_OFFSET_POSITION;
        self.castDelay = 0.5;
    }
    return self;
}

-(BOOL)isNewerWall:(Spell*)spell {
    return (spell.speed == 0 && spell.startOffsetPosition == self.startOffsetPosition) && (self.created < spell.created);
}

@end
