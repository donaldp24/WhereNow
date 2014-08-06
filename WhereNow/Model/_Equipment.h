//
//  Equipment.h
//  WhereNow
//
//  Created by Xiaoxue Han on 31/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Equipment : NSObject

@property (nonatomic) int uid;
@property (nonatomic) int genericsUid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) NSString *manufacture;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *barcode;
@property (nonatomic, strong) NSString *currentLocation;
@property (nonatomic, strong) NSString *homeLocation;

@end
