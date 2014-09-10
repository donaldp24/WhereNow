//
//  ScanManager.m
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "ScanManager.h"
#include <sys/time.h>

@interface ScanManager() {
    NSTimer *timer;
    long scanStartedTime;
    long scanEndedTime;
    BOOL bScanReceive;
}

@property (retain, nonatomic) CLBeaconRegion *beaconRegion;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL isStarted;
@property (nonatomic, retain) NSMutableArray *previousVicinityBeacons;
@property (nonatomic, retain) NSMutableArray *scannedBeacons;

@end

@implementation ScanManager

- (id)init
{
    self = [super init];
    if (self) {
        [self initMembers];
    }
    
    return self;
}

- (id)initWithDelegate:(id<ScanManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        //
    }
    
    self.delegate = delegate;
    
    [self initMembers];
    
    return self;
}

- (void)initMembers
{
    self.isStarted = NO;
    timer = nil;
    bScanReceive = NO;
}

#pragma mark - public functions

- (void)start
{
    if (self.isStarted)
        return;
    
    self.previousVicinityBeacons = [[NSMutableArray alloc] init];
    self.scannedBeacons = [[NSMutableArray alloc] init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self initRegion];
    
    self.isStarted = YES;
    
    scanEndedTime = scanStartedTime = [self getCurrentMilliTime];
    bScanReceive = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerProc:) userInfo:nil repeats:YES];
}


- (void)stop
{
    if (timer)
        [timer invalidate];
    
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
    
    self.isStarted = NO;
}

- (BOOL)isStarted
{
    return _isStarted;
}

#pragma mark - scanning

- (long)getCurrentMilliTime
{
    struct timeval time;
    gettimeofday(&time, NULL);
    long millis = (time.tv_sec * 1000) + (time.tv_usec / 1000);
    return millis;
}

- (void)timerProc:(id)tm
{
    long currTime = [self getCurrentMilliTime];
    if (bScanReceive)
    {
        if (currTime - scanStartedTime >= 10 * 1000)
        {
            scanEndedTime = currTime;
            bScanReceive = NO;
        }
    }
    else
    {
        if (currTime - scanEndedTime >= 60 * 1000)
        {
            scanEndedTime = scanStartedTime = currTime;
            bScanReceive = YES;
            
            [self compareBeaconsAndDelegate];
        }
    }
}

- (void)compareBeaconsAndDelegate
{
    // compare previous vicinity beacons
    BOOL isEqual =  YES;
    if (self.previousVicinityBeacons.count != self.scannedBeacons.count)
    {
        // not equal
        isEqual = NO;
    }
    else
    {
        for (CLBeacon *beacon in self.previousVicinityBeacons) {
            BOOL isExist = NO;
            for (CLBeacon *currBeacon in self.scannedBeacons) {
                if ([currBeacon.major intValue] == [beacon.major intValue]
                    && [currBeacon.minor intValue] == [beacon.minor intValue])
                {
                    isExist = YES;
                    break;
                }
            }
            
            if (isExist == NO)
            {
                isEqual = NO;
                break;
            }
        }
    }
    
    if (!isEqual)
    {
        self.previousVicinityBeacons = [self.scannedBeacons copy];
        
        // delegates
        if (self.delegate && [self.delegate respondsToSelector:@selector(vicinityBeaconsFound:)])
        {
            [self.delegate vicinityBeaconsFound:self.previousVicinityBeacons];
        }
    }
}

#pragma mark - internal functions
- (void)initRegion {
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:GLOBAL_UUID];
#if 0
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:HOSPITAL_MAJOR
                                                           identifier:@"com.app.BeaconRegion"];
#else
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                           identifier:@"com.app.BeaconRegion"];
#endif
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    NSLog(@"init region");
}

#pragma mark - Location Manager delegate
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    //self.lblStatus.text = @"user entered in a range of beacon";
    
    NSLog(@"didEnterRegion -- ");
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    //self.lblStatus.text = @"user exited in a range of beacon";
    
    NSLog(@"didExitRegion ---");
    
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    NSLog(@"didStartMonitoringForRegion -- ");
}


- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    if (!bScanReceive)
        return;
    
    @autoreleasepool {
        
        // when change
        for (CLBeacon *beacon in beacons) {
            int beaconMajor = [beacon.major intValue];
            int beaconMinor = [beacon.minor intValue];
            int rssi = (int)beacon.rssi;
            
            NSLog(@"beacon(%d, %d) : %d", beaconMajor, beaconMinor, rssi);
            
            if (![self isVicinity:beacon])
            {
                // not
            }
            else
            {
                // add it to vicinity array
                // check exist
                BOOL isExist = NO;
                for (CLBeacon *scannedBeacon in self.scannedBeacons) {
                    if ([scannedBeacon.major intValue] == beaconMajor &&
                        [scannedBeacon.minor intValue] == beaconMinor)
                    {
                        isExist = YES;
                        break;
                    }
                }
                if (!isExist)
                    [self.scannedBeacons addObject:beacon];
            }
        }
    }
}

#pragma mark - estimate vicinity
- (BOOL)isVicinity:(CLBeacon *)beacon
{
    if (beacon.proximity == CLProximityUnknown)
        return NO;
    if (beacon.proximity == CLProximityFar)
        return NO;
    if (beacon.proximity == CLProximityNear)
        return YES;
    if (beacon.proximity == CLProximityImmediate)
        return YES;
    return NO;
}

#pragma mark - Utility functions for location service
+ (BOOL)locationServiceEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

+ (BOOL)permissionEnabled
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        return YES;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        return NO;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        return NO;
    }
    return NO;
}


@end
