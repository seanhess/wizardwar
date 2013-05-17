//
//  Match.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Match.h"
#import "Spell.h"

@implementation Match
-(id)init {
    if ((self = [super init])) {
        self.players = [NSMutableArray array];
        self.spells = [NSMutableArray array];
    }
    return self;
}

-(void)update:(NSTimeInterval)dt {
    [self.spells enumerateObjectsUsingBlock:^(Spell* spell, NSUInteger idx, BOOL *stop) {
        [spell update:dt];
    }];
}

@end
