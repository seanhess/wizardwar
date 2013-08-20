//
//  EffectSleep.h
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "PlayerEffect.h"
#import "EffectApply.h"

@interface EffectSleep : EffectApply
-(BOOL)sleepShouldEndAtTick:(NSInteger)currentTick interval:(NSTimeInterval)interval;
@end
