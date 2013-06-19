//
//  WizardSprite.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "CCSprite.h"
#import "Wizard.h"

@interface WizardSprite : CCSprite
@property (nonatomic, strong) Wizard * player;
-(id)initWithPlayer:(Wizard*)player units:(Units*)units;
@end
