//
//  AITacticPerfectCounter.h
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AITactic.h"

@interface AITPerfectCounter : NSObject <AITactic>
@property (nonatomic, strong) NSDictionary * counters;
+(id)counters:(NSDictionary*)counters;
@end
