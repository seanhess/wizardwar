//
//  PracticeModeAIService.h
//  WizardWar
//
//  Created by Sean Hess on 5/31/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spell.h"
#import "Simulated.h"

@protocol AIDelegate <NSObject>
-(void)aiDidCastSpell:(Spell*)spell;
@end

@interface PracticeModeAIService : NSObject <Simulated>
@property (nonatomic, weak) id<AIDelegate> delegate;
@end
