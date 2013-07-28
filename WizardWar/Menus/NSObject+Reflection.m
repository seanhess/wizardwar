//
//  NSObject+Reflection.m
//  Libros
//
//  Created by Sean Hess on 1/14/13.
//  Copyright (c) 2013 Sean Hess. All rights reserved.
//

#import "NSObject+Reflection.h"
#import <objc/runtime.h>

@implementation NSObject (Reflection)

+ (NSArray *)propertyNames
{
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    
    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    
    free(properties);
    
    return rv;
}

@end
