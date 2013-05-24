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
    return [NSArray array:self filter:match];
}

-(NSArray *)map:(id(^)(id))transform {
    return [NSArray array:self map:transform];
}

-(void)forEach:(void(^)(id))block {
    return [NSArray array:self forEach:block];
}

-(void)forEachIndex:(void(^)(int))block {
    for (int i = 0; i < self.count; i++) {
        block(i);
    }
}

-(id)find:(BOOL(^)(id))match {
    NSArray * matches = [self filter:match];
    if (matches.count == 0) return nil;
    return matches[0];
}

+(NSMutableArray*)array:(id<NSFastEnumeration>)array filter:(BOOL(^)(id))match {
    NSMutableArray * found = [NSMutableArray array];
    for (id obj in array) {
        if (match(obj)) [found addObject:obj];
    }
    return found;
}

+(NSArray*)array:(id<NSFastEnumeration>)array map:(id(^)(id))transform {
    NSMutableArray * mapped = [NSMutableArray array];
    for (id obj in array) {
        id newobj = transform(obj);
        [mapped addObject:newobj];
    }
    return mapped;
}

+(void)array:(id<NSFastEnumeration>)array forEach:(void (^)(id))block {
    id(^ignore)(id) = ^(id obj) {
        block(obj);
        return obj;
    };
    
    [self array:array map:ignore];
}

+(id)array:(id<NSFastEnumeration>)array find:(BOOL (^)(id))match {
    for (id obj in array) {
        if (match(obj)) {
            return obj;
        }
    }
    return nil;
}

@end
