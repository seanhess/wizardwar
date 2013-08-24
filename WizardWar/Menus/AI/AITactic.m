//
//  AIStrategy.m
//  WizardWar
//
//  Created by Sean Hess on 8/24/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITactic.h"

@implementation AIAction
-(id)init {
    if ((self = [super init])) {
        self.weight = 1;
        self.timeRequired = 0;
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"<AIAction %@ %@>", self.spell, self.message];
}

+(id)spell:(Spell*)spell weight:(NSInteger)weight time:(NSTimeInterval)time {
    AIAction * action = [AIAction new];
    action.spell = spell;
    action.weight = weight;
    action.timeRequired = time;
    return action;
}

+(id)spell:(Spell*)spell {
    return [AIAction spell:spell weight:1 time:spell.castDelay];
}

+(id)message:(NSString*)message {
    AIAction * action = [AIAction new];
    action.message = message;
    return action;
}

@end
