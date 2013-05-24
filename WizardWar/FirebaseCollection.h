//
//  FirebaseCollection.h
//  WizardWar
//
//  Created by Sean Hess on 5/20/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import "Objectable.h"

// Keeps a dictionary in sync with the remote node, and creates local objects of the correct type
@interface FirebaseCollection : NSObject

- (id)initWithNode:(Firebase*)node dictionary:(NSMutableDictionary*)dictionary type:(Class)type;
- (id)initWithNode:(Firebase*)node dictionary:(NSMutableDictionary*)dictionary factory:(id(^)(NSDictionary*))factory;

- (void)didAddChild:(void(^)(id))cb;
- (void)didRemoveChild:(void(^)(id))cb;
- (void)didUpdateChild:(void(^)(id))cb;

// you call these instead of adding them to your dictionary by hand
- (void)addObject:(id<Objectable>)object;
- (void)addObject:(id<Objectable>)object withName:(NSString*)name;
- (void)removeObject:(id)object;

@end
