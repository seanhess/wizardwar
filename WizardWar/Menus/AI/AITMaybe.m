//
//  AITMaybe.m
//  WizardWar
//
//  Created by Sean Hess on 8/26/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "AITMaybe.h"

@implementation AITMaybe
-(AIAction *)suggestedAction:(AIGameState *)game {
    return nil;
}
+(id)random:(NSArray*)spells max:(NSInteger)priority {
    AITMaybe * tactic = [AITMaybe new];
    return tactic;
}
@end
