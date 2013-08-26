//
//  AITWaitForCast.h
//  WizardWar
//
//  Created by Sean Hess on 8/26/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AITactic.h"

// Waits for the other guy to cast a spell
@interface AITWaitForCast : NSObject <AITactic>
@property (nonatomic, strong) NSArray* spells;
+(id)random:(NSArray*)random;
@end
