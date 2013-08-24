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

@interface AIGameState : NSObject
@property (nonatomic, strong) NSArray * spells;
@property (nonatomic, strong) Wizard * wizard;
@property (nonatomic, strong) Wizard * opponent;
@property (nonatomic, strong) Spell * lastSpellCast;
@property (nonatomic) NSInteger currentTick;
@property (nonatomic) NSTimeInterval interval;

@end
