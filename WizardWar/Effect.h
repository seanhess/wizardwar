//
//  Effect.h
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpellInteraction.h"
#import "Simulated.h"

#define EFFECT_INDEFINITE 0

@class Player;
@class Spell;

@interface Effect : NSObject
@property (nonatomic) BOOL active;
@property (nonatomic) BOOL disablesPlayer;
@property (nonatomic) BOOL cancelsOnCast;
@property (nonatomic) NSTimeInterval delay; // how long it takes to active
@property (nonatomic) NSTimeInterval duration; // how long before it wears off?

-(void)start;
-(SpellInteraction*)interactPlayer:(Player*)player spell:(Spell*)spell;
-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval player:(Player*)player;

@end
