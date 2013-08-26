//
//  AITMaybe.h
//  WizardWar
//
//  Created by Sean Hess on 8/26/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AITactic.h"

// random priority spell
@interface AITMaybe : NSObject <AITactic>
+(id)random:(NSArray*)spells max:(NSInteger)priority;
@end
