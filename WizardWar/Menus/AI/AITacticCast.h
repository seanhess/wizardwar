//
//  AIStrategyCast.h
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AITactic.h"

// casts a single kind of spell?
@interface AITacticCast : NSObject <AITactic>
@property (nonatomic, strong) NSString * spellType;
@property (nonatomic, strong) Spell * suggestedSpell;
+(id)spell:(NSString*)spellType;
@end
