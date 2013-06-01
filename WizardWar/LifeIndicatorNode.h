//
//  LifeManaIndicatorNode.h
//  WizardWar
//
//  Created by Jake Gundersen on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "cocos2d.h"
#import "Player.h"
#import "Match.h"

@interface LifeIndicatorNode : CCNode
@property (nonatomic, strong) Player * player;
@property (nonatomic, strong) Match * match;
@end
