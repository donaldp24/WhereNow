//
//  BackgroundTaskManager.h
//  WhereNow
//
//  Created by Xiaoxue Han on 08/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScanManager.h"
#import "BackgroundNotifications.h"

@interface BackgroundTaskManager : NSObject <ScanManagerDelegate>

+ (BackgroundTaskManager *)sharedManager;

@property (nonatomic, retain) ScanManager *scanManager;

/**
 * locateArray
 */
@property (nonatomic, strong) NSMutableArray *locateArray;

@property (nonatomic, strong) NSMutableArray *arrayNearmeGenerics;
@property (nonatomic, strong) NSMutableArray *arrayVicinityEquipments;
@property (nonatomic, strong) NSMutableArray *arrayLocationEquipments;

- (void)startScanning;
- (void)stopScanning;

- (NSMutableArray *)nearmeBeacons;

- (void)requestLocationInfo:(NSMutableArray *)arrayBeacons complete:(void(^)())complete;

@end
