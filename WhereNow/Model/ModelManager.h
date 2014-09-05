//
//  ModelManager.h
//  WhereNow
//
//  Created by Xiaoxue Han on 06/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "Generic.h"
#import "Equipment.h"
#import "GenericLocation.h"
#import "EquipMovement.h"
#import "Alert.h"
#import "MovementCount.h"

#define SQLITE_DB_NAME      @"wherenow.sqlite"

@interface ModelManager : NSObject

@property (strong, readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, readonly, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;



+ (ModelManager *)sharedManager;

- (void)initModelManager;

- (void)saveContext;

- (NSMutableArray *)retrieveFavoritesGenerics;

- (NSMutableArray *)retrieveFavoritesEquipments;

- (NSMutableArray *)retrieveGenerics;

- (NSMutableArray *)retrieveEquipmentsWithHasBeacon:(BOOL)withBeacon;

- (NSMutableArray *)locationsForGeneric:(Generic *)generic;

- (NSMutableArray *)equipmentsForGeneric:(Generic *)generic withBeacon:(BOOL)withBeacon;

- (NSMutableArray *)retrieveGenericsWithKeyword:(NSString *)keyword;

- (NSMutableArray *)searchGenericsWithArray:(NSArray *)genericArray withKeyworkd:(NSString *)keyword;

- (NSMutableArray *)retrieveEquipmentsWithKeyword:(NSString *)keyword;

- (NSMutableArray *)searchEquipmentsWithArray:(NSArray *)equipmentArray withKeyword:(NSString *)keyword;

- (NSMutableArray *)searchEquipmentsWithGenerics:(Generic *)generic withKeyword:(NSString *)keyword;

- (NSMutableArray *)equipmovementsForEquipment:(Equipment *)equipment;

- (NSMutableArray *)retrieveAlertsForEquipment:(Equipment *)equipment;

- (NSMutableArray *)retrieveMovementCountForEquipment:(Equipment *)equipment;

- (NSMutableArray *)retrieveRecentGenerics;

- (NSMutableArray *)retrieveRecentEquipments;

- (void)addRecentGeneric:(Generic *)generic;
- (void)addRecentEquipment:(Equipment *)equipment;


@end
