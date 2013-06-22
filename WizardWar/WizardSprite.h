//
//  WizardSprite.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "CCSprite.h"
#import "Wizard.h"
#import "Match.h"

@interface WizardSprite : CCSprite

@property (nonatomic, strong) Wizard * wizard;

-(id)initWithWizard:(Wizard*)wizard units:(Units*)units match:(Match*)match isCurrentWizard:(BOOL)isCurrentWizard;
@end
