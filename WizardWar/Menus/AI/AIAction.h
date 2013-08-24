//
//  AIAction.h
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spell.h"

@interface AIAction : NSObject
@property (nonatomic) NSInteger weight; // how much we want to do this action
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) Spell * spell;
@property (nonatomic) NSTimeInterval timeRequired; // the castDelay, etc. 0 for message.
+(id)spell:(Spell*)spell weight:(NSInteger)weight time:(NSTimeInterval)time;
+(id)spell:(Spell*)spell time:(NSTimeInterval)time;
+(id)spell:(Spell*)spell;
+(id)message:(NSString*)message;
@end
