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
         */
        
        NSMutableArray *arrayNewMovements = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dicMovement in arrayMovements) {
            
            int ble_location_id = [[dicMovement objectForKey:@"ble_location_id"] intValue];
            NSString *location_name = [dicMovement objectForKey:@"location_name"];
            NSString *check_in_date = [dicMovement objectForKey:@"check_in_date"];
            int equipment_id = [[dicMovement objectForKey:@"equipment_id"] intValue];
            NSString *date = [dicMovement objectForKey:@"date"];
            NSString *time = [dicMovement objectForKey:@"time"];
            NSString *stay_time = [dicMovement objectForKey:@"stay_time"];
            
            
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
         */
        
        NSMutableArray *arrayNewLocations = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dicLocation in arrayLocations) {
            int generic_id = [[dicLocation objectForKey:@"generic_id"] intValue];
            NSString *generic_name = (NSString *)[dicLocation objectForKey:@"generic_name"];
            int ble_location_id = [[dicLocation objectForKey:@"ble_location_id"] intValue];
            NSString *location_name = (NSString *)[dicLocation objectForKey:@"location_name"];
            int location_wise_equipment_count = [[dicLocation objectForKey:@"location_wise_equipment_count"] intValue];
            int optimal_level = [[dicLocation objectForKey:@"optimal_level"] intValue];
            int warning_level = [[dicLocation objectForKey:@"warning_level"] intValue];
            int minimum_level = [[dicLocation objectForKey:@"minimum_level"] intValue];
            
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
            arrayExistEquipments = [[ModelManager sharedManager] equipmentsForGeneric:generic];
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
         

         movement_array	array

         */
        
        NSMutableArray *arrayNewEquipments = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dicEquipment in arrayEquipments) {
            
            int generic_id = [[dicEquipment objectForKey:@"generic_id"] intValue];
            NSString *generic_name = (NSString *)[dicEquipment objectForKey:@"generic_name"];
            
            int equipment_id = [[dicEquipment objectForKey:@"equipment_id"] intValue];
            NSString *serial_no = [dicEquipment objectForKey:@"serial_no"];
            NSString *barcode_no = [dicEquipment objectForKey:@"barcode_no"];
            int current_location_id = [[dicEquipment objectForKey:@"current_location_id"] intValue];
            NSString *current_location = [dicEquipment objectForKey:@"current_location"];
            NSString *manufacurer_name = [dicEquipment objectForKey:@"manufacturer_name"];
            NSString *model_name_no = [dicEquipment objectForKey:@"model_name_no"];
            int home_location_id = [[dicEquipment objectForKey:@"home_location_id"] intValue];
            NSString *home_location = [dicEquipment objectForKey:@"home_location"];
            if (home_location == nil || [home_location isEqual:[NSNull null]])
                home_location = @"";
            
            NSArray *movement_array = [dicEquipment objectForKey:@"movement_array"];
            
            BOOL isfavorites = NO;
            
            
            
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
                
                equipment.isfavorites = @(isfavorites);
                
                [arrayNewEquipments addObject:equipment];
                
                if (movement_array)
                    [self parseMovements:movement_array withEquipment:existEquipment];
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
            int generic_id = [[dicGeneric objectForKey:@"generic_id"] intValue];
            NSString *generic_name = (NSString *)[dicGeneric objectForKey:@"generic_name"];
            int genericwipse_equipment_count = [[dicGeneric objectForKey:@"genericwise_equipment_count"] intValue];
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
                existGeneric.genericwise_equipment_count = [NSNumber numberWithInt:genericwipse_equipment_count];
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
                newGeneric.genericwise_equipment_count = [NSNumber numberWithInt:genericwipse_equipment_count];
                newGeneric.isfavorites = @(isfavorites);
                newGeneric.note = note;
                
                [arrayNewGenerics addObject:newGeneric];
            }

            
            NSArray *locationArray = (NSArray *)[dicGeneric objectForKey:@"location_array"];
            NSArray *equipmentArray = (NSArray *)[dicGeneric objectForKey:@"equipment_array"];

            // locations for generic
            if (locationArray)
                [self parseLoations:locationArray withGeneric:existGeneric];
           
            // equipments for generic
            if (equipmentArray)
                [self parseEquipments:equipmentArray withGeneric:existGeneric];
        }
    }
    
    [[ModelManager sharedManager] saveContext];
    
    return bRet;
}


@end
