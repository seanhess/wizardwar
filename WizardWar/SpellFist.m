//
//  SpellFist.m
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellFist.h"
#import "SpellHelmet.h"

@implementation SpellFist

-(id)init {
    if ((self=[super init])) {
        self.speed = 0;
        self.strength = 1;
        self.altitude = 2; // it's up high!
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.altitude = 1;
            
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.altitude = 0;
            });
        });
    }
    return self;
}

-(void)setPositionFromPlayer:(Wizard*)player {
    self.direction = 1;
    
    if (player.position == UNITS_MIN)
        self.referencePosition = UNITS_MAX;
    else
        self.referencePosition = UNITS_MIN;
    
    self.position = self.referencePosition;
}

-(SpellInteraction*)interactSpell:(Spell*)spell {
    
    if ([spell isType:[SpellHelmet class]]) {
        return [SpellInteraction cancel];
    }
    
    return [SpellInteraction nothing];
}


@end
