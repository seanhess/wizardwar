//
//  NSArray+Functional.h
//  Libros
//
//  Created by Sean Hess on 1/29/13.
//  Copyright (c) 2013 Sean Hess. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Functional)

-(NSMutableArray*)filter:(BOOL(^)(id))block;
-(NSMutableArray*)map:(id(^)(id))block;
-(void)forEach:(void(^)(id))block;
-(void)forEachIndex:(void(^)(int))block;
-(id)find:(BOOL(^)(id))block;
-(id)max:(float(^)(id))block;
-(id)min:(float(^)(id))block;
-(id)randomItem;

+(NSMutableArray*)array:(id<NSFastEnumeration>)array filter:(BOOL(^)(id))block;
+(id)array:(id<NSFastEnumeration>)array find:(BOOL(^)(id))block;
+(NSMutableArray*)array:(id<NSFastEnumeration>)array map:(id(^)(id))block;
+(void)array:(id<NSFastEnumeration>)array forEach:(void(^)(id))block;

@end
