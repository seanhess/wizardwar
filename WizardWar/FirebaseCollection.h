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

// Does it manage its own data, or just keep a mutable array in sync or something?
// It could just keep a mutable dictionary in sync (that's what it actually IS)

// always mutable
@interface FirebaseCollection : NSObject

- (id)initWithNode:(Firebase*)node type:(Class)type dictionary:(NSMutableDictionary*)dictionary;

- (void)didAddChild:(void(^)(id))cb;
- (void)didRemoveChild:(void(^)(id))cb;
- (void)didUpdateChild:(void(^)(id))cb;

// you can't set the index of an object, just add it to the collection
- (void)addObject:(id<Objectable>)object;
- (void)addObject:(id<Objectable>)object withName:(NSString*)name;
- (void)removeObject:(id)object;

@end
