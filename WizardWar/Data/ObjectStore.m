//
//  ObjectStore.m
//  Libros
//
//  Created by Sean Hess on 1/11/13.
//  Copyright (c) 2013 Sean Hess. All rights reserved.
//
// I need to store some stuff
// it needs to know the application directory
// so a singleton with some initialization

#import "ObjectStore.h"
#import "NSArray+Functional.h"

@interface ObjectStore()

- (NSURL *)applicationDocumentsDirectory;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@end




@implementation ObjectStore

+ (ObjectStore *)shared
{
    static ObjectStore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ObjectStore alloc] init];
    });
    return sharedInstance;
}





#pragma mark - Objects
-(void)objectRemove:(NSManagedObject*)remove {
    [self.context deleteObject:remove];
}

#pragma mark - Helpers

-(void)requestRemove:(NSFetchRequest*)request {
    NSArray * results = [self requestToArray:request];
    [results forEach:^(NSManagedObject*object) {
        [self.context deleteObject:object];
    }];
}

-(NSArray*)requestToArray:(NSFetchRequest *)request {
    NSError * error = nil;
    NSArray * results = [ObjectStore.shared.context executeFetchRequest:request error:&error];
    if (error) self.lastError = error;
    return results;
}

-(NSManagedObject*)requestLastObject:(NSFetchRequest *)request {
    request.fetchLimit = 1;
    return [[self requestToArray:request] lastObject];
}

-(id)insertNewObjectForEntityForName:(NSString*)entityName {
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
}

//-(NSEntityDescription*)entityForName:(NSString*)name {
//    return [NSEntityDescription entityForName:name inManagedObjectContext:self.context];
//}

-(NSFetchedResultsController*)fetchedResultsForRequest:(NSFetchRequest*)request {
    return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
}


-(NSManagedObjectID*)objectIdForURI:(NSString*)uri {
    NSURL * url = [NSURL URLWithString:uri];
    return [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:url];
}

-(id)objectWithId:(NSManagedObjectID*)objectId create:(BOOL)create {
    // Load the object, or a "fault" object if it doesn't exist
    NSManagedObject * object = [self.context objectWithID:objectId];
    
    // If it doesn't exist, then if create=YES, insert, otherwise return nil
    if (!object.isInserted) {
        if (create) {
            [self.context insertObject:object];
        }
        else {
            object = nil;
        }
        
    }
    return object;
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DataModel.sqlite"];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"ObjectStore: Unresolved error %@, %@", error, [error userInfo]);
        self.lastError = error;
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext
{
    NSLog(@"ObjectStore: saveContext!");
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"ObjectStore: Unresolved error %@, %@", error, [error userInfo]);
            self.lastError = error;
        } 
    }
}

- (NSManagedObjectContext *)context {
    return self.managedObjectContext;
}


@end
