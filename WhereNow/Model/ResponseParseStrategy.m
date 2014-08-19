//
//  ResponseParseStrategy.m
//  WhereNow
//
//  Created by Xiaoxue Han on 07/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "ResponseParseStrategy.h"
#import "ServerManager.h"
#import "ModelManager.h"

#define GET_SAFE_INT(dest, dic, key, default)     \
    int dest; \
    if ([dic objectForKey:key] == nil || [[dic objectForKey:key] isEqual:[NSNull null]]) \
        dest = default; \
    else \
        dest = [[dic objectForKey:key] intValue];

#define GET_SAFE_STRING(dest, dic, key, default)    \
    NSString *dest; \
    if ([dic objectForKey:key] == nil || [[dic objectForKey:key] isEqual:[NSNull null]]) \
        dest = default; \
    else    \
        dest = [dic objectForKey:key];

static ResponseParseStrategy *_sharedParseStrategy = nil;

@implementation ResponseParseStrategy

+ (ResponseParseStrategy *)sharedParseStrategy
{
    if (_sharedParseStrategy == nil)
        _sharedParseStrategy = [[ResponseParseStrategy alloc] init];
    return _sharedParseStrategy;
}

- (BOOL)parseMovements:(NSArray *)arrayMovements withEquipment:(Equipment *)equipment
{
    @autoreleasepool {
        NSArray *arrayExistMovements = nil;
        if (equipment) {
            arrayExistMovements = [[ModelManager sharedManager] equipmovementsForEquipment:equipment];
        }
        
        /*
         ble_location_id	number
         
         location_name	string
         
         check_in_date	string
         
         equipment_id	number
         
         date	string
         
         time	string
         
         stay_time	string
         
         time_limit long seconds
         
         direction IN or OUT
         
         stay_minutes long (minutes for stay_time)
         */
        
        NSMutableArray *arrayNewMovements = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dicMovement in arrayMovements) {
           
            GET_SAFE_INT(ble_location_id, dicMovement, @"ble_location_id", 0);
            GET_SAFE_STRING(location_name, dicMovement, @"location_name", @"");
            GET_SAFE_STRING(check_in_date, dicMovement, @"check_in_date", @"");
            GET_SAFE_INT(equipment_id, dicMovement, @"equipment_id", 0);
            GET_SAFE_STRING(date, dicMovement, @"date", @"");
            GET_SAFE_STRING(time, dicMovement, @"time", @"");
            GET_SAFE_STRING(stay_time, dicMovement, @"stay_time", @"");
            GET_SAFE_INT(time_limit, dicMovement, @"time_limit", 0);
            GET_SAFE_STRING(direction, dicMovement, @"direction", @"");
            GET_SAFE_INT(stay_minutes, dicMovement, @"stay_minutes", 0);
            
            
            EquipMovement *existMovement = nil;
            
            if (!equipment)
            {
                existMovement = nil;
            }
            else
            {
                
                for (EquipMovement *movement in arrayExistMovements) {
                    if ([movement.ble_location_id intValue] == ble_location_id
                         && [movement.check_in_date isEqualToString:check_in_date])
                    {
                        existMovement = movement;
                        break;
                    }
                }
            }
            
            if (existMovement)
            {
                existMovement.ble_location_id = @(ble_location_id);
                existMovement.location_name = location_name;
                existMovement.check_in_date = check_in_date;
                existMovement.equipment_id = @(equipment_id);
                existMovement.date = date;
                existMovement.time = time;
                existMovement.stay_time = stay_time;
                existMovement.stay_minutes = @(stay_minutes);
                existMovement.time_limit = @(time_limit);
                existMovement.direction = direction;
                
                
                [arrayNewMovements addObject:existMovement];
            }
            else
            {
                EquipMovement *movement = [NSEntityDescription
                                             insertNewObjectForEntityForName:@"EquipMovement"
                                             inManagedObjectContext:[ModelManager sharedManager].managedObjectContext];

                movement.ble_location_id = @(ble_location_id);
                movement.location_name = location_name;
                movement.check_in_date = check_in_date;
                movement.equipment_id = @(equipment_id);
                movement.date = date;
                movement.time = time;
                movement.stay_time = stay_time;
                movement.stay_minutes = @(stay_minutes);
                movement.time_limit = @(time_limit);
                movement.direction = direction;
                
                [arrayNewMovements addObject:movement];
            }
        }
        
        // delete objects
        if (equipment)
        {
            for (EquipMovement *existMovement in arrayExistMovements) {
                if (![arrayNewMovements containsObject:existMovement])
                {
                    [[ModelManager sharedManager].managedObjectContext deleteObject:existMovement];
                }
            }
        }
    }
    return YES;
}

- (BOOL)parseLoations:(NSArray *)arrayLocations withGeneric:(Generic *)generic
{
    @autoreleasepool {
        NSArray *arrayExistLocations = nil;
        if (generic) {
            arrayExistLocations = [[ModelManager sharedManager] locationsForGeneric:generic];
        }
        
        /*
         generic_id	number
         
         generic_name	string
         
         ble_location_id	number
         
         location_name	string
         
         location_wise_equipment_count	number
         
         optimal_level	number
         
         warning_level	number
         
         minimum_level	number
         
         [location_hierarchy] => Array
             (
                 [0] => Array
                 (
                     [ble_location_id] => 16
                     [company_id] => 1132
                     [location_parent_id] => 2
                     [location_name] => Ward B
                 )
                 [1] => Array
                 (
                     [ble_location_id] => 2
                     [company_id] => 1132
                     [location_parent_id] => 1
                     [location_name] => Level 1
                 )
                 [2] => Array
                 (
                     [ble_location_id] => 1
                     [company_id] => 1132
                     [location_parent_id] => 0
                     [location_name] => Main Building
                 )
            )

         */
        
        NSMutableArray *arrayNewLocations = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dicLocation in arrayLocations) {
            GET_SAFE_INT(generic_id, dicLocation, @"generic_id", 0);
            GET_SAFE_STRING(generic_name, dicLocation, @"generic_name", @"");
            GET_SAFE_INT(ble_location_id, dicLocation, @"ble_location_id", 0);
            GET_SAFE_STRING(location_name, dicLocation, @"location_name", @"");
            GET_SAFE_INT(location_wise_equipment_count, dicLocation, @"location_wise_equipment_count", 0);
            GET_SAFE_INT(optimal_level, dicLocation, @"optimal_level", 0);
            GET_SAFE_INT(warning_level, dicLocation, @"warning_level", 0);
            GET_SAFE_INT(minimum_level, dicLocation, @"minimum_level", 0);

            
            NSMutableArray *arrayHierarchy = [dicLocation objectForKey:@"location_hierarchy"];
            
            NSString *note = @"";
            
            GenericLocation *existLocation = nil;
            
            if (!generic)
            {
                existLocation = nil;
            }
            else
            {
                
                for (GenericLocation *location in arrayExistLocations) {
                    if ([location.ble_location_id intValue] == ble_location_id)
                    {
                        existLocation = location;
                        break;
                    }
                }
            }
            
            if (existLocation)
            {
                existLocation.generic_id = [NSNumber numberWithInt:generic_id];
                existLocation.generic_name = generic_name;
                existLocation.ble_location_id = [NSNumber numberWithInt:ble_location_id];
                existLocation.location_name = location_name;
                existLocation.location_wise_equipment_count = [NSNumber numberWithInt:location_wise_equipment_count];
                existLocation.optimal_level = [NSNumber numberWithInt:optimal_level];
                existLocation.warning_level = [NSNumber numberWithInt:warning_level];
                existLocation.minimum_level = [NSNumber numberWithInt:minimum_level];
                existLocation.note = note;
                
                [arrayNewLocations addObject:existLocation];
                
                // parse arrayHierarchy
            }
            else
            {
                GenericLocation *location = [NSEntityDescription
                                             insertNewObjectForEntityForName:@"GenericLocation"
                                             inManagedObjectContext:[ModelManager sharedManager].managedObjectContext];
                location.generic_id = [NSNumber numberWithInt:generic_id];
                location.generic_name = generic_name;
                location.ble_location_id = [NSNumber numberWithInt:ble_location_id];
                location.location_name = location_name;
                location.location_wise_equipment_count = [NSNumber numberWithInt:location_wise_equipment_count];
                location.optimal_level = [NSNumber numberWithInt:optimal_level];
                location.warning_level = [NSNumber numberWithInt:warning_level];
                location.minimum_level = [NSNumber numberWithInt:minimum_level];
                location.note = note;
                
                [arrayNewLocations addObject:location];
                
                // parse arrayHierarchy
            }
            
            // arrayHierarchy
            if (arrayHierarchy)
            {
                for (NSDictionary *dicHierarchy in arrayHierarchy) {
                    /*
                    int h_ble_location_id = [[dicHierarchy objectForKey:@"ble_location_id"] intValue];
                    int h_company_id = [[dicHierarchy objectForKey:@"company_id"] intValue];
                    int h_location_parent_id = [[dicHierarchy objectForKey:@"location_parent_id"] intValue];
                    NSString *h_location_name = [dicHierarchy objectForKey:@"location_name"];
                     */
                }
            }
        }
        
        // delete objects
        if (generic)
        {
            for (GenericLocation *existLocation in arrayExistLocations) {
                if (![arrayNewLocations containsObject:existLocation])
                {
                    [[ModelManager sharedManager].managedObjectContext deleteObject:existLocation];
                }
            }
        }
    }
    return YES;
}


- (BOOL)parseEquipments:(NSArray *)arrayEquipments withGeneric:(Generic *)generic
{
    @autoreleasepool {
        NSArray *arrayExistEquipments = nil;
        if (generic) {
            arrayExistEquipments = [[ModelManager sharedManager] equipmentsForGeneric:generic withBeacon:YES];
        }
        
        /*
         generic_id	number
         
         generic_name	string
         
         equipment_id	number
         
         serial_no	string
         
         barcode_no	string
         
         currernt_location_id	number
         
         current_location	string
         
         manufacturer_name	string
         
         model_name_no	string
         
         home_location_id	number
         
         
         home_location	string
         
         model_id
         

         movement_array	array
         
         equipment_file_location
         
         model_file_location

         */
        
        NSMutableArray *arrayNewEquipments = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dicEquipment in arrayEquipments) {
            GET_SAFE_INT(generic_id, dicEquipment, @"generic_id", 0);
            GET_SAFE_STRING(generic_name, dicEquipment, @"generic_name", @"");
            GET_SAFE_INT(equipment_id, dicEquipment, @"equipment_id", 0);
            GET_SAFE_STRING(serial_no, dicEquipment, @"serial_no", @"");
            GET_SAFE_STRING(barcode_no, dicEquipment, @"barcode_no", @"");
            GET_SAFE_INT(current_location_id, dicEquipment, @"current_location_id", 0);
            GET_SAFE_STRING(current_location, dicEquipment, @"current_location", @"");
            GET_SAFE_STRING(manufacurer_name, dicEquipment, @"manufacturer_name", @"");
            GET_SAFE_STRING(model_name_no, dicEquipment, @"model_name_no", @"");
            GET_SAFE_INT(home_location_id, dicEquipment, @"home_location_id", 0);
            GET_SAFE_STRING(home_location, dicEquipment, @"home_location", @"");

            
            NSArray *movement_array = [dicEquipment objectForKey:@"movement_array"];
            
            BOOL isfavorites = NO;
            
            GET_SAFE_STRING(model_id, dicEquipment, @"model_id", @"");
            GET_SAFE_STRING(equipment_file_location, dicEquipment, @"equipment_file_location", @"");
            GET_SAFE_STRING(model_file_location, dicEquipment, @"model_file_location", @"");
            
            NSString *equipment_file_location_local = @"";
            NSString *model_file_location_local = @"";
            
            
            
            Equipment *existEquipment = nil;
            
            if (!generic)
            {
                existEquipment = nil;
            }
            else
            {
                for (Equipment *equipment in arrayExistEquipments) {
                    if ([equipment.equipment_id intValue] == equipment_id)
                    {
                        existEquipment = equipment;
                        break;
                    }
                }
            }
            
            if (existEquipment)
            {
                existEquipment.generic_id = [NSNumber numberWithInt:generic_id];
                existEquipment.generic_name = generic_name;
                existEquipment.equipment_id = [NSNumber numberWithInt:equipment_id];
                existEquipment.serial_no = serial_no;
                existEquipment.barcode_no = barcode_no;
                existEquipment.current_location_id = [NSNumber numberWithInt:current_location_id];
                existEquipment.current_location = current_location;
                existEquipment.manufacturer_name = manufacurer_name;
                existEquipment.model_name_no = model_name_no;
                existEquipment.home_location_id = [NSNumber numberWithInt:home_location_id];
                existEquipment.home_location = home_location;
                existEquipment.has_beacon = @(YES);
                
                existEquipment.model_id = model_id;
                
                if (![existEquipment.equipment_file_location isEqualToString:equipment_file_location])
                {
                    // resave file to local
                    existEquipment.equipment_file_location = equipment_file_location;
                }
                
                if (![existEquipment.model_file_location isEqualToString:model_file_location])
                {
                    // resave file to local
                    existEquipment.model_file_location = model_file_location;
                }

                
                [arrayNewEquipments addObject:existEquipment];
                
                if (movement_array)
                    [self parseMovements:movement_array withEquipment:existEquipment];
            }
            else
            {
                Equipment *equipment = [NSEntityDescription
                                             insertNewObjectForEntityForName:@"Equipment"
                                             inManagedObjectContext:[ModelManager sharedManager].managedObjectContext];
                equipment.generic_id = [NSNumber numberWithInt:generic_id];
                equipment.generic_name = generic_name;
                equipment.equipment_id = [NSNumber numberWithInt:equipment_id];
                equipment.serial_no = serial_no;
                equipment.barcode_no = barcode_no;
                equipment.current_location_id = [NSNumber numberWithInt:current_location_id];
                equipment.current_location = current_location;
                equipment.manufacturer_name = manufacurer_name;
                equipment.model_name_no = model_name_no;
                equipment.home_location_id = [NSNumber numberWithInt:home_location_id];
                equipment.home_location = home_location;
                equipment.has_beacon = @(YES);
                
                equipment.isfavorites = @(isfavorites);
                
                equipment.model_id = model_id;
                
                equipment.equipment_file_location = equipment_file_location;
                equipment.model_file_location = model_file_location;
                
                // have to save file to local
                existEquipment.equipment_file_location_local = equipment_file_location_local;
                existEquipment.model_file_location_local = model_file_location_local;
                
                existEquipment.isrecent = @(NO);
                existEquipment.recenttime = [NSDate date];
                
                [arrayNewEquipments addObject:equipment];
                
                if (movement_array)
                    [self parseMovements:movement_array withEquipment:existEquipment];
                else
                    [self parseMovements:[[NSMutableArray alloc] init] withEquipment:existEquipment];
            }
        }
        
        // delete objects
        if (generic)
        {
            for (Equipment *existEquipment in arrayExistEquipments) {
                if (![arrayNewEquipments containsObject:existEquipment])
                {
                    [[ModelManager sharedManager].managedObjectContext deleteObject:existEquipment];
                }
            }
        }
    }
    return YES;
}

- (BOOL)parseGenericResponse:(NSDictionary *)dicResult
{
    BOOL bRet = YES;
    
    @autoreleasepool {
        
        NSArray *arrayExistGenerics = [[ModelManager sharedManager] retrieveGenerics];
        NSMutableArray *arrayNewGenerics = [[NSMutableArray alloc] init];
        
        NSArray *arrayResult = (NSArray *)dicResult;
        for (NSDictionary *dicGeneric in arrayResult) {
            
            // generic
            GET_SAFE_INT(generic_id, dicGeneric, @"generic_id", 0);
            GET_SAFE_STRING(generic_name, dicGeneric, @"generic_name", @"");
            GET_SAFE_INT(genericwise_equipment_count, dicGeneric, @"genericwise_equipment_count", 0);

            BOOL isfavorites = NO;
            NSString *note = @"";
            
            Generic *newGeneric = nil;
            
            // is exist
            Generic *existGeneric = nil;
            for (Generic *generic in arrayExistGenerics) {
                if ([generic.generic_id intValue] == generic_id)
                {
                    existGeneric = generic;
                    break;
                }
            }
            
            // if is exist, update values
            if (existGeneric)
            {
                existGeneric.generic_id = [NSNumber numberWithInt:generic_id];
                existGeneric.generic_name = generic_name;
                existGeneric.genericwise_equipment_count = [NSNumber numberWithInt:genericwise_equipment_count];
                existGeneric.note = note;
                
                [arrayNewGenerics addObject:existGeneric];
            }
            else
            {
                // insert generic
                newGeneric = [NSEntityDescription
                                insertNewObjectForEntityForName:@"Generic"
                                inManagedObjectContext:[ModelManager sharedManager].managedObjectContext];
                
                newGeneric.generic_id = [NSNumber numberWithInt:generic_id];
                newGeneric.generic_name = generic_name;
                newGeneric.genericwise_equipment_count = [NSNumber numberWithInt:genericwise_equipment_count];
                newGeneric.isfavorites = @(isfavorites);
                newGeneric.note = note;
                
                newGeneric.isrecent = @(NO);
                newGeneric.recenttime = [NSDate date];
                
                [arrayNewGenerics addObject:newGeneric];
            }

            
            NSArray *locationArray = (NSArray *)[dicGeneric objectForKey:@"location_array"];
            NSArray *equipmentArray = (NSArray *)[dicGeneric objectForKey:@"equipment_array"];

            // locations for generic
            if (locationArray)
                [self parseLoations:locationArray withGeneric:existGeneric];
            else
                [self parseLoations:[[NSMutableArray alloc] init] withGeneric:existGeneric];
           
            // equipments for generic
            if (equipmentArray)
                [self parseEquipments:equipmentArray withGeneric:existGeneric];
            else
                [self parseEquipments:[[NSMutableArray alloc] init] withGeneric:existGeneric];
        }
    }
    
    [[ModelManager sharedManager] saveContext];
    
    return bRet;
}

- (BOOL)parseEquipmentResponse:(NSDictionary *)dicResult
{
    BOOL bRet = YES;
    @autoreleasepool {
        // parse dic result
        NSMutableArray *arrayExistEquipments = [[ModelManager sharedManager] retrieveEquipmentsWithHasBeacon:NO];
        NSMutableArray *arrayNewEquipments = [[NSMutableArray alloc] init];
        
        NSArray *arrayResult = (NSArray *)dicResult;
        for (NSDictionary *dicEquipment in arrayResult) {
            /*
             [generic_id] => 323
             [generic_name] => PC UNIT
             [equipment_id] => 2696
             [serial_no] => 12858495
             [barcode_no] => 232I56
             [manufacturer_name] => HEALTHSTREAM
             [model_name_no] => 8015 SERIES
             [model_id] => 1378
             */
            GET_SAFE_INT(generic_id, dicEquipment, @"generic_id", 0);
            GET_SAFE_STRING(generic_name, dicEquipment, @"generic_name", @"");
            GET_SAFE_INT(equipment_id, dicEquipment, @"equipment_id", 0);
            GET_SAFE_STRING(serial_no, dicEquipment, @"serial_no", @"");
            GET_SAFE_STRING(barcode_no, dicEquipment, @"barcode_no", @"");
            GET_SAFE_STRING(manufacturer_name, dicEquipment, @"manufacturer_name", @"");
            GET_SAFE_STRING(model_name_no, dicEquipment, @"model_name_no", @"");
            GET_SAFE_STRING(model_id, dicEquipment, @"model_id", @"");
            
            // is exist
            Equipment *existEquipment = nil;
            for (Equipment *equipment in arrayExistEquipments) {
                if ([equipment.equipment_id intValue] == equipment_id)
                {
                    existEquipment = equipment;
                    break;
                }
            }
            
            if (existEquipment)
            {
                existEquipment.generic_id = @(generic_id);
                existEquipment.generic_name = generic_name;
                existEquipment.equipment_id = @(equipment_id);
                existEquipment.serial_no = serial_no;
                existEquipment.barcode_no = barcode_no;
                existEquipment.manufacturer_name = manufacturer_name;
                existEquipment.model_name_no = model_name_no;
                existEquipment.model_id = model_id;
                
                [arrayNewEquipments addObject:existEquipment];
            }
            else
            {
                Equipment *equipment = [NSEntityDescription
                                        insertNewObjectForEntityForName:@"Equipment"
                                        inManagedObjectContext:[ModelManager sharedManager].managedObjectContext];
                equipment.generic_id = @(generic_id);
                equipment.generic_name = generic_name;
                equipment.equipment_id = @(equipment_id);
                equipment.serial_no = serial_no;
                equipment.barcode_no = barcode_no;
                equipment.manufacturer_name = manufacturer_name;
                equipment.model_name_no = model_name_no;
                equipment.model_id = model_id;
                
                equipment.current_location_id = @(0);
                equipment.current_location = @"";
                equipment.home_location_id = @(0);
                equipment.home_location = @"";
                
                equipment.has_beacon = @(NO);
                
                equipment.equipment_file_location = @"";
                equipment.model_file_location = @"";
                equipment.equipment_file_location_local = @"";
                equipment.model_file_location_local = @"";
                
                [arrayNewEquipments addObject:equipment];
            }
        }
        
        
        // if there is equipment in old array but in new array, delete object in old array
        for (Equipment *existEquipment in arrayExistEquipments) {
            if (![arrayNewEquipments containsObject:existEquipment])
            {
                // delete object
                [[ModelManager sharedManager].managedObjectContext deleteObject:existEquipment];
            }
        }
    }
    return bRet;
}

- (BOOL)parseNearmeResponse:(NSDictionary *)dicResult complete:(void (^)(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments))complete failure:(void(^)())failure
{
    NSMutableArray *arrayGenerics = [[NSMutableArray alloc] init];
    NSMutableArray *arrayVicinityEquipments = [[NSMutableArray alloc] init];
    NSMutableArray *arrayLocationEquipments = [[NSMutableArray alloc] init];
    
    NSMutableArray *arrayExistGenerics = [[ModelManager sharedManager] retrieveGenerics];
    NSMutableArray *arrayExistEquipments = [[ModelManager sharedManager] retrieveEquipmentsWithHasBeacon:YES];
    
    NSArray *arrayResult = (NSArray *)dicResult;
    for (NSDictionary *dicGeneric in arrayResult) {
        int generic_id = [[dicGeneric objectForKey:@"generic_id"] intValue];
        
        Generic *generic = [self genericWithGenericId:generic_id generics:arrayExistGenerics];
        if (generic == nil)
            continue;
        
        if (![arrayGenerics containsObject:generic])
            [arrayGenerics addObject:generic];
        
        NSArray *arrayEquipments = [dicGeneric objectForKey:@"equipment_array"];
        if (arrayEquipments != nil)
        {
            for (NSDictionary *dicEquipment in arrayEquipments) {
                int equipment_id = [[dicEquipment objectForKey:@"equipment_id"] intValue];
                Equipment *equipment = [self equipmentWithEquipmentId:equipment_id equipments:arrayExistEquipments];
                if (equipment == nil)
                    continue;
                
                NSString *location_type = [dicEquipment objectForKey:@"location_type"];
                if ([location_type isEqualToString:@"IMMEDIATE VICINITY"])
                {
                    if (![arrayVicinityEquipments containsObject:equipment])
                        [arrayVicinityEquipments addObject:equipment];
                }
                else
                {
                    if (![arrayLocationEquipments containsObject:equipment])
                        [arrayLocationEquipments addObject:equipment];
                }
            }
        }
    }
    
    complete(arrayGenerics, arrayVicinityEquipments, arrayLocationEquipments);
    return YES;
}

- (Generic *)genericWithGenericId:(int)generic_id generics:(NSMutableArray *)arrayGenerics
{
    for (Generic *generic in arrayGenerics) {
        if ([generic.generic_id intValue] == generic_id)
            return generic;
    }
    return nil;
}

- (Equipment *)equipmentWithEquipmentId:(int)equipment_id equipments:(NSMutableArray *)arrayEquipments
{
    for (Equipment *equipment in arrayEquipments) {
        if ([equipment.equipment_id intValue] == equipment_id)
            return equipment;
    }
    return nil;
}


@end
