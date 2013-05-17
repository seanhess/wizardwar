//
//  SpellInteraction.m
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "SpellInteraction.h"
#import "Spell.h"

@implementation SpellInteraction

-(id)initWithType:(SpellInteractionType)type {
    if ((self = [super init])) {
        self.type = type;
    }
    return self;
}

+(SpellInteraction*)nothing {
    return [[SpellInteraction alloc] initWithType:SpellInteractionTypeNothing];
}

+(SpellInteraction*)cancel {
    return [[SpellInteraction alloc] initWithType:SpellInteractionTypeNothing];
}

+(SpellInteraction*)modify {
    return [[SpellInteraction alloc] initWithType:SpellInteractionTypeNothing];
}

+(SpellInteraction*)create:(Spell*)spell {
    SpellInteraction * interaction = [[SpellInteraction alloc] initWithType:SpellInteractionTypeNothing];
    interaction.createdSpell = spell;
    return interaction;
}

@end
