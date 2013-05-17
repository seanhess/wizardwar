//
//  SpellInteraction.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Spell;

typedef enum SpellInteractionType {
    SpellInteractionTypeNothing,
    SpellInteractionTypeCancel,
    SpellInteractionTypeModify,
    SpellInteractionTypeCreate,
} SpellInteractionType;

@interface SpellInteraction : NSObject

@property (nonatomic) SpellInteractionType type;
@property (nonatomic, strong) Spell * createdSpell;

-(id)initWithType:(SpellInteractionType)type;

+(SpellInteraction*)nothing;
+(SpellInteraction*)cancel;
+(SpellInteraction*)modify;
+(SpellInteraction*)create:(Spell*)spell;

@end
