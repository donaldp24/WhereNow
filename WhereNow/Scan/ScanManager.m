//
//  ScanManager.m
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "ScanManager.h"
#include <sys/time.h>
#import <snfsdk/snfsdk.h>

#define kScanForEveryCertainSecs     1
#define kScanPeriodOnce             13
#define kScanTimout                 13

@interface ScannedBeacon : NSObject

@property (nonatomic, retain) CLBeacon *beacon;
@property (nonatomic) long lastScannedTime;

@end

@implementation ScannedBeacon


@end

@interface ScanManager() {
    NSTimer *timer;
    long scanStartedTime;
    long scanEndedTime;
    int scanningMethod;
    long lastDelegateTime;
}

@property (retain, nonatomic) CLBeaconRegion *beaconRegion;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL isStarted;

@property (nonatomic, retain) NSMutableArray *prevScannedBeacons;
@property (nonatomic, retain) NSMutableArray *currScannedBeacons;

// sticknfind
@property (nonatomic, retain) LeDeviceManager *snfDeviceManager;

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
    
    scanningMethod = kScanForEveryCertainSecs;
    self.scanMode = ScanModeNormal;
}

#pragma mark - public functions

- (void)start
{
    if (self.isStarted)
        return;
    
    self.prevScannedBeacons = [[NSMutableArray alloc] init];
    self.currScannedBeacons = [[NSMutableArray alloc] init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [self.locationManager requestAlwaysAuthorization];
#endif
    
    self.locationManager.delegate = self;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    [self initRegion];
    
    self.isStarted = YES;
    
    scanEndedTime = scanStartedTime = [self getCurrentMilliTime];
    
    lastDelegateTime = [self getCurrentMilliTime];
    
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

- (void)changeMode:(ScanMode)scanMode
{
    if (self.scanMode == scanMode)
        return;
    
    
    if (scanMode == ScanModeNormal)
    {
        scanEndedTime = [self getCurrentMilliTime];
    }
    
    _scanMode = scanMode;
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
}

- (void)compareBeaconsAndDelegate
{
    // compare previous vicinity beacons
    BOOL isEqual =  YES;
    if (self.prevScannedBeacons.count != self.currScannedBeacons.count)
    {
        // not equal
        isEqual = NO;
    }
    else
    {
        for (ScannedBeacon *scannedBeacon in self.prevScannedBeacons) {
            BOOL isExist = NO;
            for (ScannedBeacon *currScannedBeacon in self.currScannedBeacons) {
                if ([currScannedBeacon.beacon.major intValue] == [scannedBeacon.beacon.major intValue]
                    && [currScannedBeacon.beacon.minor intValue] == [scannedBeacon.beacon.minor intValue])
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
    
    NSLog(@"compareBeaconsAndDelegate : %@\n %@\n%@", self.prevScannedBeacons, self.currScannedBeacons, (isEqual?@"same":@"Different"));
   
    if (!isEqual)
    {
        self.prevScannedBeacons = self.currScannedBeacons;
        self.currScannedBeacons = [[NSMutableArray alloc] init];
        
        // delegates
        if (self.delegate && [self.delegate respondsToSelector:@selector(didVicinityBeaconsFound:)])
        {
            NSMutableArray *arrayBeacons = [[NSMutableArray alloc] init];
            for (ScannedBeacon *scannedBeacon in self.prevScannedBeacons) {
                [arrayBeacons addObject:scannedBeacon.beacon];
            }
            [self.delegate didVicinityBeaconsFound:arrayBeacons];
        }
    }
    else
    {
        NSMutableArray *arrayBeacons = [[NSMutableArray alloc] init];
        for (ScannedBeacon *scannedBeacon in self.currScannedBeacons) {
            [arrayBeacons addObject:scannedBeacon.beacon];
        }
        [self.delegate didBeaconsFound:arrayBeacons];
        self.currScannedBeacons = [[NSMutableArray alloc] init];
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
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    self.beaconRegion.notifyOnEntry = YES;
    self.beaconRegion.notifyOnExit = YES;
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
    {
        NSLog(@"error : cannot monitoring for class : clbeaconregion");
    }
    
    if (![CLLocationManager isRangingAvailable])
    {
        NSLog(@"error : cannot ranging");
    }
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    //[self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    NSLog(@"init region");
}

#pragma mark - Location Manager delegate
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    //[self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    //self.lblStatus.text = @"user entered in a range of beacon";
    
    NSLog(@"didEnterRegion -- ");
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    //[self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    //self.lblStatus.text = @"user exited in a range of beacon";
    
    NSLog(@"didExitRegion ---");
    
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    NSLog(@"didStartMonitoringForRegion -- ");
}


- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    NSLog(@"didRangeBeacons : %@", beacons);
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        //
    }
    else
    {
        // expand time
    }
    
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
            for (ScannedBeacon *scannedBeacon in self.currScannedBeacons) {
                if ([scannedBeacon.beacon.major intValue] == beaconMajor &&
                    [scannedBeacon.beacon.minor intValue] == beaconMinor)
                {
                    isExist = YES;
                    scannedBeacon.lastScannedTime = [self getCurrentMilliTime];
                    break;
                }
            }
            if (!isExist)
            {
                ScannedBeacon *newBeacon = [[ScannedBeacon alloc] init];
                newBeacon.beacon = beacon;
                newBeacon.lastScannedTime = [self getCurrentMilliTime];
                [self.currScannedBeacons addObject:newBeacon];
            }
        }
    }
    
    if (self.scanMode == ScanModeNormal)
    {
        
        // check time
        //if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
  
        NSLog(@"get curr time");
            long currTime = [self getCurrentMilliTime];
            if (currTime - lastDelegateTime > kScanPeriodOnce * 1000)
            {
                NSLog(@"compare and delegate");
                [self compareBeaconsAndDelegate];
                lastDelegateTime = [self getCurrentMilliTime];
            }
        //}
        //else {
        //    [self compareBeaconsAndDelegate];
        //}
        
    }
    else if (self.scanMode == ScanModeNearme)
    {
        //[self.queue addOperationWithBlock:^() {
            long currTime = [self getCurrentMilliTime];
            
            // remove timed out beacons --------------------
            NSMutableArray *removeBeacons = [[NSMutableArray alloc] init];
            for (ScannedBeacon *scannedBeacon in self.currScannedBeacons) {
                if (currTime - scannedBeacon.lastScannedTime > kScanTimout * 1000)
                {
                    [removeBeacons addObject:scannedBeacon];
                }
            }
            
            for (ScannedBeacon *scannedBeacon in removeBeacons) {
                [self.currScannedBeacons removeObject:scannedBeacon];
            }
            
            // compare two arrays
            BOOL isEqual = YES;
            if (self.prevScannedBeacons.count != self.currScannedBeacons.count)
            {
                isEqual = NO;
            }
            else
            {
                for (ScannedBeacon *scannedBeacon in self.prevScannedBeacons) {
                    BOOL isExist = NO;
                    for (ScannedBeacon *currScannedBeacon in self.currScannedBeacons) {
                        if ([currScannedBeacon.beacon.major intValue] == [scannedBeacon.beacon.major intValue]
                            && [currScannedBeacon.beacon.minor intValue] == [scannedBeacon.beacon.minor intValue])
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
                self.prevScannedBeacons = [self.currScannedBeacons copy];
                NSMutableArray *vicinityBeacons = [[NSMutableArray alloc] init];
                for (ScannedBeacon *scannedBeacon in self.currScannedBeacons) {
                    [vicinityBeacons addObject:scannedBeacon.beacon];
                }
                
                //if (self.delegate && currTime - lastDelegateTime > 10 * 1000)
                {
                    [self.delegate didVicinityBeaconsFound:vicinityBeacons];
                    lastDelegateTime = [self getCurrentMilliTime];
                }
            }
            else
            {
                if (self.delegate && currTime - lastDelegateTime > 10 * 1000)
                {
                    NSMutableArray *arrayBeacons = [[NSMutableArray alloc] init];
                    for (ScannedBeacon *scannedBeacon in self.currScannedBeacons) {
                        [arrayBeacons addObject:scannedBeacon.beacon];
                    }
                    [self.delegate didBeaconsFound:arrayBeacons];
                    lastDelegateTime = [self getCurrentMilliTime];
                }
            }
        //}];
    }

}

#pragma mark - estimate vicinity
- (BOOL)isVicinity:(CLBeacon *)beacon
{
    if (beacon.proximity == CLProximityUnknown)
        return NO;
    if (beacon.proximity == CLProximityFar)
        return YES;
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
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        return YES;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        return YES;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        return NO;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return NO;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        return NO;
    }
    return NO;
#else
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        return YES;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        return YES;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        return NO;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return NO;
    }
    return NO;
#endif
}


@end
