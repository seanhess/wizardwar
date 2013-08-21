//
//  EffectHeal.h
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "PlayerEffect.h"
#import "PEApply.h"

#define EFFECT_HEAL_TIME 3.0

@interface PEHeal : PEApply
+(id)delay:(NSTimeInterval)delay;
@end
