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
@property (nonatomic, strong) void(^addCb)(id);
@property (nonatomic, strong) void(^removeCb)(id);
@property (nonatomic, strong) void(^updateCb)(id);
@end

@implementation FirebaseCollection

- (id)initWithNode:(Firebase*)node dictionary:(NSMutableDictionary *)dictionary type:(__unsafe_unretained Class)type {
    return [self initWithNode:node dictionary:dictionary factory:^(NSDictionary * value) {
        return [type new];
    }];
}

- (id)initWithNode:(Firebase*)node dictionary:(NSMutableDictionary*)dictionary factory:(id(^)(NSDictionary*))factory {
    self = [super init];
    if (self) {
        self.objects = dictionary;
        self.node = node;
        self.names = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsObjectPointerPersonality valueOptions:NSPointerFunctionsWeakMemory];
        
        self.addCb = ^(id obj) {};
        self.removeCb = ^(id obj) {};
        self.updateCb = ^(id obj) {};
        
        // find the correct object and update locally
        [self.node observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
            id<Objectable> obj = [self.objects objectForKey:snapshot.name];
            if (!obj) {
                // add the object to the collection if it doesn't exist yet
                obj = factory(snapshot.value);
                [self addObjectLocally:obj name:snapshot.name];
            }
            // update the object with values from the server and notify the delegate
            [obj setValuesForKeysWithDictionary:snapshot.value];
            self.addCb(obj);
        }];
        
        [self.node observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
            id<Objectable> obj = [self.objects objectForKey:snapshot.name];
            if (!obj) return;
            [self.objects removeObjectForKey:snapshot.name];
            self.removeCb(obj);
        }];
        
        [self.node observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
            id<Objectable> obj = [self.objects objectForKey:snapshot.name];
            if (!obj) {
                NSAssert(false, @"Object not found locally! %@", snapshot.name);
            }
            [obj setValuesForKeysWithDictionary:snapshot.value];
            self.updateCb(obj);
        }];
    }
    return self;
}

- (void)didAddChild:(void(^)(id))cb {
    self.addCb = cb;
}

- (void)didRemoveChild:(void(^)(id))cb {
    self.removeCb = cb;
}

- (void)didUpdateChild:(void(^)(id))cb {
    self.updateCb = cb;
}

- (void)removeObject:(id<Objectable>)object {
    [[self nodeForObject:object] removeValue];
}

- (void)addObject:(id<Objectable>)obj {
    [self addObject:obj onComplete:nil];
}

- (void)addObject:(id<Objectable>)obj withName:(NSString *)name {
    [self addObject:obj withName:name onComplete:nil];
}

- (void)addObject:(id<Objectable>)obj onComplete:(void (^)(NSError*))cb {
    [self addObject:obj withNode:[self.node childByAutoId] onComplete:cb];
}

- (void)addObject:(id<Objectable>)obj withName:(NSString *)name onComplete:(void (^)(NSError*))cb {
    [self addObject:obj withNode:[self.node childByAppendingPath:name] onComplete:cb];
}

- (void)addObject:(id<Objectable>)obj withNode:(Firebase*)objnode onComplete:(void(^)(NSError*))cb {
//    if (!cb) cb = ^(NSError*error) {};
    [objnode onDisconnectRemoveValue];
    [objnode setValue:obj.toObject withCompletionBlock:cb];
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

- (void)updateObject:(id<Objectable>)obj {
    [[self nodeForObject:obj] setValue:obj.toObject];
}

- (Firebase*)nodeForObject:(id<Objectable>)obj {
    NSString * name = [self.names objectForKey:obj];
    Firebase* objnode = [self.node childByAppendingPath:name];
    return objnode;
}

- (void)dealloc {
    [self.node removeAllObservers];
}

@end
