//
//  AITacticCastOnHit.h
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AITactic.h"

@interface AITacticCastOnHit : NSObject <AITactic>
@property (nonatomic, strong) NSArray * spells;
@property (nonatomic) BOOL hitSelf;
@property (nonatomic) BOOL hitOpponent;
+(id)me:(BOOL)me opponent:(BOOL)opponent random:(NSArray*)spells;
@end
