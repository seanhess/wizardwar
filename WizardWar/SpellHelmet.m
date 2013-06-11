//
//  SpellFist.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellHelmet.h"

@implementation SpellHelmet

-(id)init {
    if ((self=[super init])) {
        self.speed = 0;
        self.strength = 1;
        self.altitude = 1;
    }
    return self;
}

-(void)setPositionFromPlayer:(Player*)player {
    self.direction = 1;
    if (!player.isFirstPlayer)
        self.direction = -1;
    self.referencePosition = player.position;
    self.position = self.referencePosition;
}

-(SpellInteraction*)interactSpell:(Spell*)spell {
    
    if ([spell isType:[SpellHelmet class]])
        return [SpellInteraction cancel];
    
    return [SpellInteraction nothing];
}


@end
