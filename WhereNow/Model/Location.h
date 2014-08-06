//
//  Location.h
//  WhereNow
//
//  Created by Xiaoxue Han on 04/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Equipment;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * parentUid;
@property (nonatomic, retain) NSNumber * companyUid;
@property (nonatomic, retain) NSSet *equipments;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addEquipmentsObject:(Equipment *)value;
- (void)removeEquipmentsObject:(Equipment *)value;
- (void)addEquipments:(NSSet *)values;
- (void)removeEquipments:(NSSet *)values;

@end
