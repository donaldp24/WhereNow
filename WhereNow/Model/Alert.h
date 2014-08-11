//
//  Alert.h
//  WhereNow
//
//  Created by Xiaoxue Han on 11/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Alert : NSManagedObject

@property (nonatomic, retain) NSNumber * alert_id;
@property (nonatomic, retain) NSString * alert_type;
@property (nonatomic, retain) NSString * location_level;
@property (nonatomic, retain) NSString * location_name;
@property (nonatomic, retain) NSString * note1;
@property (nonatomic, retain) NSString * note2;

@end
