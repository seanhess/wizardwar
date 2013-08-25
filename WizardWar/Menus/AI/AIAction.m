//
//  AIAction.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AIAction.h"

@implementation AIAction
-(id)init {
    if ((self = [super init])) {
        self.priority = 0;
        self.timeRequired = 0;
    }
    return self;
}

-(NSString*)description {
    NSString * messageString = (self.message) ? self.message : @"";
    return [NSString stringWithFormat:@"<AIAction %i %@ %@>", self.priority, self.spell.type, messageString];
}

+(id)spell:(Spell*)spell time:(NSTimeInterval)time priority:(NSInteger)priority {
    AIAction * action = [AIAction new];
    action.spell = spell;
    action.priority = priority;
    action.timeRequired = time;
    return action;
}

+(id)spell:(Spell*)spell time:(NSTimeInterval)time {
    return [AIAction spell:spell time:time priority:0];
}

+(id)spell:(Spell*)spell {
    return [AIAction spell:spell time:spell.castDelay priority:0];
}

+(id)spell:(Spell *)spell priority:(NSInteger)priority {
    return [AIAction spell:spell time:spell.castDelay priority:priority];
}

+(id)message:(NSString*)message {
    AIAction * action = [AIAction new];
    action.message = message;
    return action;
}

+(NSInteger)randomPriority:(NSInteger)max {
    return arc4random() % max;
}

@end
