//
//  AITutorial1BasicMagic.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "Tutorial.h"
#import "UIColor+Hex.h"

@interface Tutorial ()
@property (nonatomic, strong) TutorialStep * currentStep;
@end

@implementation Tutorial
@synthesize wizard = _wizard;
@synthesize opponent = _opponent;
@synthesize delegate = _delegate;
@synthesize hideControls = _hideControls;
@synthesize environment = _environment;
@synthesize disableControls = _disableControls;

-(id)init {
    if ((self = [super init])) {
        Wizard * wizard = [Wizard new];
        wizard.name = @"Horzo the Helpful";
        wizard.wizardType = WIZARD_TYPE_ONE;
        wizard.color = [UIColor colorFromRGB:0x005EA8];
        self.wizard = wizard;
        self.hideControls = YES;
        self.disableControls = YES;
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
}

-(void)simulateTick:(NSInteger)currentTick interval:(NSTimeInterval)interval {
    
}

-(void)opponent:(Wizard*)wizard didCastSpell:(Spell*)spell atTick:(NSInteger)tick {
    
}

-(BOOL)shouldPreventSpellCast:(Spell *)spell atTick:(NSInteger)tick {
    // is this how we want to do it?
    // better to pass the allowed spells to pentagram
    return NO;
}

-(void)tutorialDidTap {
    if (self.currentStep.advanceOnTap) {
        [self loadStep:self.currentStepIndex+1];
    }
}

@end
