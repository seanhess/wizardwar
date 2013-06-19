//
//  MatchLayer.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "CCLayer.h"
#import "PentagramViewController.h"
#import "Wizard.h"
#import "Match.h"

@interface MatchLayer : CCLayer
-(id)initWithMatch:(Match*)match size:(CGSize)size;
@end
