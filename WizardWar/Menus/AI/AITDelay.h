//
//  AITacticDelay.h
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AITactic.h"

@interface AITDelay : NSObject <AITactic>
@property (nonatomic) NSTimeInterval delay;
@property (nonatomic) NSTimeInterval reactionTime;
@property (nonatomic, strong) NSArray * spells;
+(id)random:(NSArray*)spells fixedDelay:(NSTimeInterval)delay;
+(id)random:(NSArray*)spells reactionTime:(NSTimeInterval)delay;
+(id)random:(NSArray*)spells;
@end
