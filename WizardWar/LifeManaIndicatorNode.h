//
//  LifeManaIndicatorNode.h
//  WizardWar
//
//  Created by Jake Gundersen on 5/18/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "cocos2d.h"

@interface LifeManaIndicatorNode : CCNode

@property (nonatomic) NSInteger health;
@property (nonatomic) NSInteger mana;

-(void)updateWithHealth:(NSInteger)health andMana:(NSInteger)mana;

@end
