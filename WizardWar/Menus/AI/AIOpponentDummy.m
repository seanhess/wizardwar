//
//  AIOpponentDummy.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AIOpponentDummy.h"
#import "UIColor+Hex.h"

@implementation AIOpponentDummy
-(id)init {
    if ((self = [super init])) {
        Wizard * wizard = [Wizard new];
        wizard.name = @"Practice Dummy";
        wizard.wizardType = WIZARD_TYPE_ONE;
        wizard.color = [UIColor colorFromRGB:0xF23953];
        self.wizard = wizard;
        
        self.tactics = @[];
    }
    return self;
}
@end
