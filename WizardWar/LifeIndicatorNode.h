//
//  LifeManaIndicatorNode.h
//  WizardWar
//
//  Created by Jake Gundersen on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "cocos2d.h"
#import "Wizard.h"
#import "Match.h"
#import "Units.h"

@interface LifeIndicatorNode : CCNode
@property (nonatomic, strong) Wizard * player;
@property (nonatomic, strong) Match * match;
-(id)initWithUnits:(Units*)units;
@end
