//
//  SpellFailUndies.m
//  WizardWar
//
//  Created by Sean Hess on 8/1/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellFailUndies.h"
#import "EffectUndies.h"

@implementation SpellFailUndies

-(id)init {
    if ((self=[super init])) {
        self.name = @"Undies";
    }
    return self;
}

-(PlayerEffect*)effect {
    return [EffectUndies new];
}


@end
