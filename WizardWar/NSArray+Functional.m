//
//  NSArray+Functional.m
//  Libros
//
//  Created by Sean Hess on 1/29/13.
//  Copyright (c) 2013 Sean Hess. All rights reserved.
//

#import "NSArray+Functional.h"

@implementation NSArray (Functional)

-(NSArray *)filter:(BOOL(^)(id))match {
    NSPredicate * predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary * bindings) {
        return match(evaluatedObject);
    }];
    
    return [self filteredArrayUsingPredicate:predicate];
}

-(NSArray *)map:(id(^)(id))tranform {
    NSMutableArray * array = [NSMutableArray array];
    for (id obj in self) {
        [array addObject:tranform(obj)];
    }
    return array;
}

-(void)forEach:(void(^)(id))block {
    id(^ignore)(id) = ^(id obj) {
        block(obj);
        return obj;
    };
    
    [self map:ignore];
}

-(id)find:(BOOL(^)(id))match {
    NSArray * matches = [self filter:match];
    if (matches.count == 0) return nil;
    return matches[0];
}

@end
