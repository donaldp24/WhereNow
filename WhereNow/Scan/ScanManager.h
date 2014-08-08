//
//  ScanManager.h
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define GLOBAL_UUID         @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
#define HOSPITAL_MAJOR      51


@protocol ScanManagerDelegate <NSObject>

@required
- (void)vicinityBeacons:(NSMutableArray *)arrayBeacons;

@end

@interface ScanManager : NSObject <CLLocationManagerDelegate>

/**
 * 
 */
@property (nonatomic, strong) id<ScanManagerDelegate> delegate;

- (id)initWithDelegate:(id<ScanManagerDelegate>)delegate;

/**
 * start ranging & monitoring beacons
 */
- (void)start;

/**
 * stop ranging & mornitoring
 */
- (void)stop;

- (BOOL)isStarted;

@end
