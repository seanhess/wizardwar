//
//  Times.m
//  WizardWar
//
//  Created by Sean Hess on 5/27/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "PlayerTime.h"

@implementation PlayerTime

-(NSDictionary*)toObject {
    return [self dictionaryWithValuesForKeys:@[@"name", @"currentTime", @"dTimeTo", @"accepted", @"dTimeFrom"]];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%@ %@", [super description], [self toObject]];
}

@end
