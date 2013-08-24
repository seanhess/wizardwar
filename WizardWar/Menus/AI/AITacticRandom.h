//
//  AITacticRandom.h
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AITactic.h"

// Casts a random spell every N seconds
@interface AITacticRandom : NSObject <AITactic>
@property (nonatomic, strong) NSArray * spells;
@property (nonatomic) NSTimeInterval delay;
@property (nonatomic) BOOL castOnHit;
+(id)spells:(NSArray*)spells delay:(NSTimeInterval)delay;
+(id)spellsCastOnHit:(NSArray*)spells;
@end
