//
//  ScanManager.h
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

//#define GLOBAL_UUID         @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define GLOBAL_UUID         @"B125AA4F-2D82-401D-92E5-F962E8037F5C"
//#define HOSPITAL_MAJOR      51

typedef NS_ENUM(NSUInteger, ScanMode) {
    ScanModeNormal,
    ScanModeNearme
};

@protocol ScanManagerDelegate <NSObject>

@required
// called when not same beacons found
- (void)didVicinityBeaconsFound:(NSMutableArray *)arrayBeacons hasNewBeacon:(BOOL)hasNewBeacon;

// called in beacon ranging callback
- (void)didBeaconsFound:(NSMutableArray *)arrayBeacons;

@end

@interface ScanManager : NSObject <CLLocationManagerDelegate>

/**
 * 
 */
@property (nonatomic, weak) id<ScanManagerDelegate> delegate;
@property (nonatomic) ScanMode scanMode;

- (id)initWithDelegate:(id<ScanManagerDelegate>)delegate;

/**
 * start ranging & monitoring beacons
 */
- (void)start;

/**
 * stop ranging & mornitoring
 */
- (void)stop;

- (void)changeMode:(ScanMode)scanMode;

- (BOOL)isStarted;



+ (BOOL)locationServiceEnabled;

+ (BOOL)permissionEnabled;

@end
