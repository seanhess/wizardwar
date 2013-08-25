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
#import "TutorialStep.h"

@protocol AIDelegate <NSObject>
-(void)aiDidCastSpell:(Spell*)spell;
@end

@protocol AIService <NSObject>
@property (nonatomic, weak) id<AIDelegate> delegate;

@property (nonatomic, strong) Wizard*wizard;
@property (nonatomic, strong) Wizard*opponent;
@property (nonatomic, strong) NSString * environment;

// for tutorials, they can hide the controls
@property (nonatomic) BOOL hideControls;
@property (nonatomic) BOOL disableControls;
@property (nonatomic, strong) NSArray* allowedSpells;
@property (nonatomic, strong) NSArray* helpSelectedElements;

-(void)didTapControls;
-(void)opponent:(Wizard*)wizard didCastSpell:(Spell*)spell atTick:(NSInteger)tick;
-(void)simulateTick:(NSInteger)tick interval:(NSTimeInterval)interval spells:(NSArray*)spells;

@end
