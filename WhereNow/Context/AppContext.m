//
//  AppContext.m
//  WhereNow
//
//  Created by Xiaoxue Han on 01/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "AppContext.h"

static AppContext *_sharedAppContext = nil;

@implementation AppContext

+ (AppContext *)sharedAppContext
{
    if (_sharedAppContext == nil)
        _sharedAppContext = [[AppContext alloc] init];
    return _sharedAppContext;
}

- (void)initContext
{
    _managedObjectContext = [self appContext];
}


#pragma mark - Core Data stack
- (NSManagedObjectContext *)appContext {
    if (self.managedObjectContext != nil) {
        return self.managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self appStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init]; [_managedObjectContext setUndoManager:nil];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)appModel
{
    if (self.managedObjectModel != nil){
        return self.managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return self.managedObjectModel;
}

- (NSPersistentStoreCoordinator *)appStoreCoordinator
{
    if (self.persistentStoreCoordinator != nil) {
        return self.persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"wherenow.sqlite"];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self appModel]];
    
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:storeURL
                                                             options:nil
                                                               error:&error])
    {
        abort();
    }
    
    return self.persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains:NSUserDomainMask]
            lastObject];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext =self.managedObjectContext;
    
    if (managedObjectContext != nil)
    {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error])
        {
            abort();
        }
    }
}

@end
