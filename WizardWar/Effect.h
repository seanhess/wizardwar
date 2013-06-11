//
//  Effect.h
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpellInteraction.h"

@class Player;
@class Spell;

@interface Effect : NSObject
@property (nonatomic) BOOL active;
@property (nonatomic) NSTimeInterval delay; // how long it takes to active

-(SpellInteraction*)interactPlayer:(Player*)player spell:(Spell*)spell;
-(void)playerDidCastSpell:(Player*)player;

@end
