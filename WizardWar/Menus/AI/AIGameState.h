//
//  AIGameState.h
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Wizard.h"
#import "Spell.h"
#import "AIAction.h"

@interface AIGameState : NSObject
@property (nonatomic, strong) NSArray * spells;
@property (nonatomic, strong) Wizard * wizard;
@property (nonatomic, strong) Wizard * opponent;

@property (nonatomic, strong) Spell * lastSpellCast;
@property (nonatomic) NSTimeInterval lastTimeRequired;

@property (nonatomic) NSInteger currentTick;
@property (nonatomic) NSInteger messageTick;
@property (nonatomic) NSTimeInterval interval;

// lets you know if you can cast since the last spell vs a delay
@property (nonatomic, readonly) NSTimeInterval timeSinceLastCast;
@property (nonatomic, readonly) NSTimeInterval timePerTick;

@property (nonatomic, readonly) NSArray * mySpells;
@property (nonatomic, readonly) NSArray * opponentSpells;
@property (nonatomic, readonly) NSArray * incomingSpells;
@property (nonatomic, readonly) Spell * activeWall;
@property (nonatomic, readonly) BOOL isCooldown; // whether the last spell made me SLOW

// can filter spells by: direction (incoming, outgoing)
// sort: when cast, so the most recent is always last?
// sort: how close they are?

-(NSArray*)sortSpellsByCreated:(NSArray*)spells;
-(NSArray*)sortSpellsByDistance:(NSArray*)spells;

-(BOOL)spells:(NSArray*)spells containsType:(NSString*)type;

@end
