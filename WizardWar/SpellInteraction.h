//
//  SpellInteraction.h
//  WizardWar
//
//  Created by Sean Hess on 8/21/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpellEffect.h"

@interface SpellInteraction : NSObject
@property (nonatomic, strong) NSString* spell;
@property (nonatomic, strong) NSString* otherSpell;
@property (nonatomic, strong) SpellEffect* effect;
@end

