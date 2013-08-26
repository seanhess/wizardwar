//
//  RACSignal+Filters.m
//  WizardWar
//
//  Created by Sean Hess on 8/26/13.
//  Copyright (c) 2013 Orbital Labs. All rights reserved.
//

#import "RACSignal+Filters.h"

@implementation RACSignal (Filters)

-(RACSignal*)safe {
    return [self map:^id(NSNumber * value) {
        if (!value) value = [NSNumber numberWithInt:0];
        return value;
    }];
}

-(RACSignal*)exists {
    return [self filter:^BOOL(id value) {
        return (value != nil);
    }];
}

@end
