//
//  AIService.h
//  WizardWar
//
//  Created by Sean Hess on 8/9/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Wizard.h"
#import "Simulated.h"

@protocol AIDelegate <NSObject>
-(void)aiDidCastSpell:(Spell*)spell;
@end

@protocol AIService <NSObject, Simulated>
@property (nonatomic, strong) Wizard*wizard;
@property (nonatomic, strong) Wizard*opponent;
@property (nonatomic, weak) id<AIDelegate> delegate;

// for tutorials, they can hide the controls
@property (nonatomic) BOOL hideControls;

-(void)tutorialDidTap;
-(void)opponent:(Wizard*)wizard didCastSpell:(Spell*)spell atTick:(NSInteger)tick;
-(BOOL)shouldPreventSpellCast:(Spell*)spell atTick:(NSInteger)tick;

@end
