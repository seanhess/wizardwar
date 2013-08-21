//
//  SpellCheeseCaptainPlanet.m
//  WizardWar
//
//  Created by Sean Hess on 8/12/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellCheeseCaptainPlanet.h"

@implementation SpellCheeseCaptainPlanet

-(id)init {
    if ((self=[super init])) {
        self.name = @"Captain Planet";
        self.damage = 0;
        self.speed = 18;
    }
    return self;
}

@end
