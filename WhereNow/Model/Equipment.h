//
//  Equipment.h
//  WhereNow
//
//  Created by Xiaoxue Han on 22/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Equipment : NSManagedObject

@property (nonatomic, retain) NSString * barcode_no;
@property (nonatomic, retain) NSString * current_location;
@property (nonatomic, retain) NSNumber * current_location_id;
@property (nonatomic, retain) NSString * equipment_file_location;
@property (nonatomic, retain) NSString * equipment_file_location_local;
@property (nonatomic, retain) NSNumber * equipment_id;
@property (nonatomic, retain) NSNumber * generic_id;
@property (nonatomic, retain) NSString * generic_name;
@property (nonatomic, retain) NSNumber * has_beacon;
@property (nonatomic, retain) NSString * home_location;
@property (nonatomic, retain) NSNumber * home_location_id;
@property (nonatomic, retain) NSNumber * isfavorites;
@property (nonatomic, retain) NSNumber * isrecent;
@property (nonatomic, retain) NSString * manufacturer_name;
@property (nonatomic, retain) NSString * model_file_location;
@property (nonatomic, retain) NSString * model_file_location_local;
@property (nonatomic, retain) NSString * model_id;
@property (nonatomic, retain) NSString * model_name_no;
@property (nonatomic, retain) NSDate * recenttime;
@property (nonatomic, retain) NSString * serial_no;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * major;
@property (nonatomic, retain) NSNumber * minor;
@property (nonatomic, retain) NSString * current_location_parent_name;
@property (nonatomic, retain) NSNumber * current_location_parent_id;

@end
