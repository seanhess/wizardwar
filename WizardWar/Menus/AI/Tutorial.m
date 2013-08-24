//
//  AITutorial1BasicMagic.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "Tutorial.h"
#import "UIColor+Hex.h"
#import <ReactiveCocoa.h>
#import "Spell.h"

@interface Tutorial ()
@property (nonatomic, strong) TutorialStep * currentStep;
@property (nonatomic) NSInteger wizardHealth;
@end

@implementation Tutorial

// Advance Conditions
// 1. cast a certain spell

-(id)init {
    if ((self = [super init])) {
        Wizard * wizard = [Wizard new];
        wizard.name = @"Horzo the Helpful";
        wizard.wizardType = WIZARD_TYPE_ONE;
        wizard.color = [UIColor colorFromRGB:0x005EA8];
        self.wizard = wizard;
        self.hideControls = YES;
        self.disableControls = YES;
        
        RAC(self.wizardHealth) = RACAbleWithStart(self.wizard.health);
    }
    return self;
}

-(void)loadStep:(NSInteger)stepIndex {
    self.currentStepIndex = stepIndex;
    if (stepIndex >= self.steps.count) return;
    TutorialStep * currentStep = self.steps[stepIndex];
    self.currentStep = currentStep;
    
    self.disableControls = currentStep.disableControls;
    self.hideControls = currentStep.hideControls;
    self.wizard.message = currentStep.message;
    self.allowedSpells = currentStep.allowedSpells;
    self.tactics = currentStep.tactics;
}

-(void)opponent:(Wizard*)wizard didCastSpell:(Spell*)spell atTick:(NSInteger)tick {
    [super opponent:wizard didCastSpell:spell atTick:tick];
    
    if (self.currentStep.advanceOnSpell && [spell isType:self.currentStep.advanceOnSpell]) {
        [self advance];
    }
}

-(void)setWizardHealth:(NSInteger)health {
    if (health < _wizardHealth && self.currentStep.advanceOnDamage) {
        [self advance];
    }
        
    _wizardHealth = health;
}

-(void)advance {
    [self loadStep:self.currentStepIndex+1];
}

-(void)didTapControls {
    if (self.currentStep.advanceOnTap) {
        [self advance];
    }
}

@end
