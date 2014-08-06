//
//  AppContext.h
//  WhereNow
//
//  Created by Xiaoxue Han on 01/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppContext : NSObject


@property (strong, readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;



+ (AppContext *)sharedAppContext;

- (void)initContext;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
