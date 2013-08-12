//
//  SpellWall.h
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Spell.h"

#define SPELL_WALL_OFFSET_POSITION 15

@interface SpellWall : Spell
-(BOOL)isNewerWall:(Spell*)spell;
@end
