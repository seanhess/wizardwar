//
//  SpellType.m
//  WizardWar
//
//  Created by Sean Hess on 8/21/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "SpellInfo.h"
#import "Spell.h"
#import "PEBasicDamage.h"

@implementation SpellInfo

-(id)init {
    if ((self = [super init])) {
        self.damage = 1; // default value
        self.speed = 30; // 30 units per second
        self.strength = 1; // destroyed is read from this
        self.startOffsetPosition = 1;
        self.targetSelf = NO;
        self.heavy = YES;
        self.castDelay = 0.8;
        self.class = [Spell class];
        self.effect = [PEBasicDamage new];
        self.isWall = NO;
    }
    return self;
}

+(SpellInfo*)type:(NSString*)type class:(Class)class {
    SpellInfo * spellType = [SpellInfo new];
    spellType.type = type;
    spellType.class = class;
    return spellType;
}

+(SpellInfo*)type:(NSString*)type {
    SpellInfo * spellType = [SpellInfo new];
    spellType.type = type;
    return spellType;    
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<SpellType: %@>", self.type];
}


@end
