//
//  Player.h
//  WizardWar
//
//  Created by Sean Hess on 5/17/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Units.h"

@interface Player : NSObject
@property (nonatomic, strong) NSString * name;
@property (nonatomic) float position; // in units (not pixels)
@property (nonatomic) NSInteger mana;
@property (nonatomic) NSInteger maxMana;
-(NSDictionary*)toObject;
-(BOOL)isFirstPlayer;
@end
