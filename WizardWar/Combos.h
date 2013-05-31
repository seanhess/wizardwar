//
//  Combos.h
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Elements.h"
#import "Spell.h"

@interface Combos : NSObject

-(Spell*)spellForElements:(NSArray*)elements;

@end
