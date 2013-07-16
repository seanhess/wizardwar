//
//  ObjectStore.h
//  Libros
//
//  Created by Sean Hess on 1/11/13.
//  Copyright (c) 2013 Sean Hess. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import <CoreData/CoreData.h>

@interface ObjectStore : NSObject

@property (strong, readonly) NSManagedObjectContext *context;
@property (strong, nonatomic) NSError * lastError;

+(ObjectStore*)shared;
-(void)saveContext;

// Objects
-(void)objectRemove:(NSManagedObject*)remove;

// Requests
-(void)requestRemove:(NSFetchRequest*)request;
-(NSArray*)requestToArray:(NSFetchRequest*)request;
-(id)requestLastObject:(NSFetchRequest*)request;
-(id)insertNewObjectForEntityForName:(NSString*)name;
-(NSFetchedResultsController*)fetchedResultsForRequest:(NSFetchRequest*)request; // section name key path, cacheName

-(NSManagedObjectID*)objectIdForURI:(NSString*)uri;
-(id)objectWithId:(NSManagedObjectID*)objectId create:(BOOL)create;

@end
