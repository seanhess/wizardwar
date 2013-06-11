//
//  SpellWall.h
//  WizardWar
//
//  Created by Sean Hess on 6/11/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "Spell.h"

@interface SpellWall : Spell
-(BOOL)isNewerWall:(Spell*)spell;
@end
