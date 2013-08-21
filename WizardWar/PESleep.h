//
//  EffectSleep.h
//  WizardWar
//
//  Created by Sean Hess on 6/13/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "PlayerEffect.h"
#import "PEApply.h"
#import "Wizard.h"

@interface PESleep : PEApply
-(BOOL)sleepShouldEndAtTick:(NSInteger)currentTick interval:(NSTimeInterval)interval wizard:(Wizard*)wizard;
@end
