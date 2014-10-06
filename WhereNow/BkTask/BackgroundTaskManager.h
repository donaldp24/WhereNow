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
#import "StickerManager.h"

@interface BackgroundTaskManager : NSObject <ScanManagerDelegate>

+ (BackgroundTaskManager *)sharedManager;

@property (nonatomic, retain) ScanManager *scanManager;
@property (nonatomic, retain) StickerManager *stickBeaconManager;

/**
 * locateArray
 */
@property (nonatomic, strong) NSMutableArray *locateArray;

@property (nonatomic, strong) NSMutableArray *arrayNearmeGenerics;
@property (nonatomic, strong) NSMutableArray *arrayVicinityEquipments;
@property (nonatomic, strong) NSMutableArray *arrayLocationEquipments;
//@property (nonatomic, strong) NSMutableArray *arrayLocatingEquipments;

- (void)startScanning;
- (void)stopScanning;

- (NSMutableArray *)nearmeBeacons;

- (void)requestLocationInfo:(NSMutableArray *)arrayBeacons complete:(void(^)())complete;

- (void)changeToStickBeaconMode;
- (void)cancelStickBeaconMode;

@end
