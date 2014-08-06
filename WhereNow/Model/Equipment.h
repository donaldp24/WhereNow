//
//  Equipment.h
//  WhereNow
//
//  Created by Xiaoxue Han on 04/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Generics, Location;

@interface Equipment : NSManagedObject

@property (nonatomic, retain) NSString * barcode;
@property (nonatomic, retain) NSString * currentLocation;
@property (nonatomic, retain) NSString * homeLocation;
@property (nonatomic, retain) NSString * img;
@property (nonatomic, retain) NSNumber * isFavorites;
@property (nonatomic, retain) NSString * manufacture;
@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * serialNumber;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) Generics *generics;
@property (nonatomic, retain) Location *location;

@end
