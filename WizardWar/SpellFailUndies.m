//
//  SpellFailUndies.m
//  WizardWar
//
//  Created by Sean Hess on 8/1/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellFailUndies.h"
#import "PEUndies.h"

@implementation SpellFailUndies

-(id)init {
    if ((self=[super init])) {
        self.name = @"Undies";
        self.damage = 0;        
    }
    return self;
}


@end
