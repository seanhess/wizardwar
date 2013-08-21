//
//  SpellWall.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellWall.h"

@implementation SpellWall

-(id)initWithInfo:(SpellInfo *)info {
    if ((self=[super initWithInfo:info])) {
        self.speed = 0;
        self.damage = 0;
        self.strength = 3;
        self.startOffsetPosition = SPELL_WALL_OFFSET_POSITION;
        self.castDelay = 0.5;
    }
    return self;
}

@end
