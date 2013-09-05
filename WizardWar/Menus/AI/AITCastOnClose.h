//
//  AITCastOnClose.h
//  WizardWar
//
//  Created by Sean Hess on 8/25/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AITactic.h"

@interface AITCastOnClose : NSObject <AITactic>
@property (nonatomic) float distance;
@property (nonatomic, strong) NSString * highSpell;
@property (nonatomic, strong) NSString * lowSpell;
// @property (nonatomic)
// different
// if we are currently altitude = 1, then cast helmet
// if we are currently altitude = 0, then cast levitate
+(id)distance:(float)distance highSpell:(NSString*)high lowSpell:(NSString*)low;
@end
