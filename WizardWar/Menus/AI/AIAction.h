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
@property (nonatomic) NSInteger priority; // highest priority wins. Default is 0
@property (nonatomic, strong) NSString * message;
@property (nonatomic) BOOL clearMessage;
@property (nonatomic, strong) Spell * spell;
@property (nonatomic) NSTimeInterval timeRequired; // the castDelay, etc. 0 for message.
+(id)spell:(Spell*)spell time:(NSTimeInterval)time priority:(NSInteger)priority;
+(id)spell:(Spell*)spell time:(NSTimeInterval)time;
+(id)spell:(Spell*)spell; // uses the spell castDelay
+(id)spell:(Spell*)spell priority:(NSInteger)priority; // uses the spell castDelay
+(id)message:(NSString*)message; // messages are free!
+(id)clearMessage;
+(NSInteger)randomPriority:(NSInteger)max; // lets you add randomness if you want
@end
