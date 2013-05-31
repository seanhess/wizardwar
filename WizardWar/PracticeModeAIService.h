//
//  PracticeModeAIService.h
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spell.h"

@protocol AIDelegate <NSObject>
-(void)aiDidCastSpell:(Spell*)spell;
@end

@interface PracticeModeAIService : NSObject
@property (nonatomic, weak) id<AIDelegate> delegate;
-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval;
@end
