//
//  AIOpponentSettings.m
//  WizardWar
//
//  Created by Sean Hess on 8/26/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AIOpponentFactory.h"
#import "Wizard.h"
#import "AIOpponent.h"

@implementation AIOpponentFactory

- (id)init {
    if ((self = [super init])) {
        self.AIType = [AIOpponent class];
    }
    return self;
}

- (id<AIService>)create {
    AIOpponent * opponent = [self.AIType new];
    
    if (self.tactics) {
        opponent.tactics = self.tactics;
    }
    
    if (!opponent.wizard) {
        Wizard * wizard = [Wizard new];
        wizard.name = self.name;
        wizard.colorRGB = self.colorRGB;
        wizard.wizardType = WIZARD_TYPE_ONE;
        opponent.wizard = wizard;
    }
    
    return opponent;
}

+(id)withType:(Class)AIType {
    AIOpponentFactory * factory = [AIOpponentFactory new];
    factory.AIType = AIType;
    return factory;
}

+(id)withColor:(NSUInteger)color tactics:(NSArray*)tactics {
    AIOpponentFactory * factory = [AIOpponentFactory new];
    factory.colorRGB = color;
    factory.tactics = tactics;
    return factory;
}

@end
