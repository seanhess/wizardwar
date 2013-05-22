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

@protocol FirebaseCollectionDelegate <NSObject>
-(void)didAddChild:(id)object;
-(void)didRemoveChild:(id)object;
-(void)didUpdateChild:(id)object;
@end

// always mutable
@interface FirebaseCollection : NSObject

@property (weak, nonatomic) id<FirebaseCollectionDelegate>delegate;

- (id)initWithNode:(Firebase*)node type:(Class)type dictionary:(NSMutableDictionary*)dictionary;

// you can't set the index of an object, just add it to the collection
- (void)addObject:(id<Objectable>)object;
- (void)addObject:(id<Objectable>)object withName:(NSString*)name;
- (void)removeObject:(id)object;

@end
