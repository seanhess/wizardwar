//
//  Times.m
//  WizardWar
//
//  Created by Sean Hess on 5/27/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "GameTime.h"

@implementation GameTime

-(NSDictionary*)toObject {
    return [self dictionaryWithValuesForKeys:@[@"name", @"nextTick", @"nextTickTime", @"gameTime"]];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@ %@", [super description], [self toObject]];
}

@end
