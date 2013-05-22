//
//  FirebaseCollection.m
//  WizardWar
//
//  Created by Sean Hess on 5/20/13.
//  Copyright (c) 2013 The LAB. All rights reserved.
//

#import "FirebaseCollection.h"

@interface FirebaseCollection ()
@property (nonatomic, strong) Firebase * node;
@property (nonatomic, strong) NSMutableDictionary * objects;
@property (nonatomic, strong) NSMapTable * names;
@property (nonatomic, strong) Class type;
@end

@implementation FirebaseCollection

- (id)initWithNode:(Firebase*)node type:(__unsafe_unretained Class)type dictionary:(NSMutableDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.objects = dictionary;
        self.node = node;
        self.names = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsObjectPointerPersonality valueOptions:NSPointerFunctionsWeakMemory];
        
        // find the correct object and update locally
        [self.node observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
            id obj = [self.objects objectForKey:snapshot.name];
            if (!obj) {
                // add the object to the collection if it doesn't exist yet
                obj = [type new];
                [self addObjectLocally:obj name:snapshot.name];
            }
            // update the object with values from the server and notify the delegate
            [obj setValuesForKeysWithDictionary:snapshot.value];
            [self.delegate didAddChild:obj];
        }];
        
        [self.node observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
            id obj = [self.objects objectForKey:snapshot.name];
            if (!obj) return;
            [self.objects removeObjectForKey:snapshot.name];
            [self.delegate didRemoveChild:obj];
        }];
        
        [self.node observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
            id obj = [self.objects objectForKey:snapshot.name];
            if (!obj) {
                NSAssert(false, @"Object not found locally! %@", snapshot.name);
            }
            [obj setValuesForKeysWithDictionary:snapshot.value];
            [self.delegate didUpdateChild:obj];
        }];
    }
    return self;
}

- (void)removeObject:(id<Objectable>)object {
    NSString * name = [self.names objectForKey:object];
    Firebase * objnode = [self.node childByAppendingPath:name];
    [objnode removeValue];
}

- (void)addObject:(id<Objectable>)obj {
    [self addObject:obj withNode:[self.node childByAutoId]];
}

- (void)addObject:(id<Objectable>)obj withName:(NSString *)name {
    [self addObject:obj withNode:[self.node childByAppendingPath:name]];
}

- (void)addObject:(id<Objectable>)obj withNode:(Firebase*)objnode {
    [objnode onDisconnectRemoveValue];
    [objnode setValue:obj.toObject];
    [self addObjectLocally:obj name:objnode.name];
}

- (void)addObjectLocally:(id)obj name:(NSString*)name {
    [self.names setObject:name forKey:obj];
    [self.objects setObject:obj forKey:name];
}

- (void)removeObjectLocally:(id)obj name:(NSString*)name {
    [self.names removeObjectForKey:obj];
    [self.objects removeObjectForKey:name];
}

- (void)dealloc {
    [self.node removeAllObservers];
}

@end
