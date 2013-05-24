//
//  WizardSprite.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "CCSprite.h"
#import "Player.h"

@interface WizardSprite : CCSprite
@property (nonatomic, strong) Player * player;
-(id)initWithPlayer:(Player*)player units:(Units*)units;
@end
