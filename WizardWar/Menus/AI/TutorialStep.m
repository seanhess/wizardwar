//
//  TutorialStep.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "TutorialStep.h"

@implementation TutorialStep

+(id)modalMessage:(NSString *)message {
    TutorialStep * step = [TutorialStep new];
    step.message = message;
    step.advanceOnTap = YES;
    step.hideControls = YES;
    step.disableControls = YES;
    return step;
}

+(id)message:(NSString*)message hideControls:(BOOL)hideControls {
    TutorialStep * step = [TutorialStep new];
    step.message = message;
    step.advanceOnTap = YES;
    step.hideControls = hideControls;
    step.disableControls = YES;
    return step;
}

+(id)message:(NSString*)message disableControls:(BOOL)disableControls {
    TutorialStep * step = [TutorialStep new];
    step.message = message;
    step.advanceOnTap = YES;
    step.hideControls = NO;
    step.disableControls = disableControls;
    return step;
}

+(id)message:(NSString*)message {
    TutorialStep * step = [TutorialStep new];
    step.message = message;
    return step;
}

+(id)message:(NSString*)message allowedSpells:(NSArray*)allowed {
    TutorialStep * step = [TutorialStep new];
    step.message = message;
    step.allowedSpells = allowed;
    return step;
}

@end
