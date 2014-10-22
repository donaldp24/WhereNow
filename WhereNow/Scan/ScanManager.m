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

#define kScanFor10SecsPerMin        0
#define kScanForEveryCertainSecs     1
#define kScanPeriodOnce             10
#define kScanTimout                 10

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
    BOOL bScanReceive;
    int scanningMethod;
    long lastDelegateTime;
}

@property (retain, nonatomic) CLBeaconRegion *beaconRegion;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL isStarted;
@property (nonatomic, retain) NSMutableArray *previousVicinityBeacons;
@property (nonatomic, retain) NSMutableArray *scannedBeacons;

// nearme mode
@property (nonatomic, retain) NSMutableArray *scannedBeaconsForNearmeMode;
@property (nonatomic, retain) NSMutableArray *prevScannedBeaconsForNearmeMode;

// sticknfind
@property (nonatomic, retain) LeDeviceManager *snfDeviceManager;

@property (nonatomic, retain) NSOperationQueue *queue;

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
    
    scanningMethod = kScanForEveryCertainSecs;
    self.scanMode = ScanModeNormal;
    
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
}

#pragma mark - public functions

- (void)start
{
    if (self.isStarted)
        return;
    
    self.previousVicinityBeacons = [[NSMutableArray alloc] init];
    self.scannedBeacons = [[NSMutableArray alloc] init];
    
    // nearme mode
    self.prevScannedBeaconsForNearmeMode = [[NSMutableArray alloc] init];
    self.scannedBeaconsForNearmeMode = [[NSMutableArray alloc] init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [self.locationManager requestAlwaysAuthorization];
#endif
    
    self.locationManager.delegate = self;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    [self initRegion];
    
    self.isStarted = YES;
    
    scanEndedTime = scanStartedTime = [self getCurrentMilliTime];
    bScanReceive = YES;
    
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
    if (self.scanMode == ScanModeNormal)
    {
        long currTime = [self getCurrentMilliTime];
        if (scanningMethod == kScanFor10SecsPerMin)
        {
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
        else
        {
#if 0
            if (currTime - scanEndedTime >= kScanPeriodOnce * 1000)
            {
                scanEndedTime = currTime;
                
                [self compareBeaconsAndDelegate];
            }
#endif
        }
    }
    else if (self.scanMode == ScanModeNearme)
    {
#if 0
        [self.queue addOperationWithBlock:^() {
            long currTime = [self getCurrentMilliTime];
            NSMutableArray *removeBeacons = [[NSMutableArray alloc] init];
            for (ScannedBeacon *scannedBeacon in self.scannedBeaconsForNearmeMode) {
                if (currTime - scannedBeacon.lastScannedTime > kScanTimout * 1000)
                {
                    [removeBeacons addObject:scannedBeacon];
                }
            }
            
            for (ScannedBeacon *scannedBeacon in removeBeacons) {
                [self.scannedBeaconsForNearmeMode removeObject:scannedBeacon];
            }
            
            // compare two arrays
            BOOL isEqual = YES;
            if (self.prevScannedBeaconsForNearmeMode.count != self.scannedBeaconsForNearmeMode.count)
            {
                isEqual = NO;
            }
            else
            {
                for (ScannedBeacon *scannedBeacon in self.prevScannedBeaconsForNearmeMode) {
                    BOOL isExist = NO;
                    for (ScannedBeacon *currScannedBeacon in self.scannedBeaconsForNearmeMode) {
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
                self.prevScannedBeaconsForNearmeMode = [self.scannedBeaconsForNearmeMode copy];
                NSMutableArray *vicinityBeacons = [[NSMutableArray alloc] init];
                for (ScannedBeacon *scannedBeacon in self.scannedBeaconsForNearmeMode) {
                    [vicinityBeacons addObject:scannedBeacon.beacon];
                }
                
                if (self.delegate)
                {
                    [self.delegate didVicinityBeaconsFound:vicinityBeacons];
                    lastDelegateTime = [self getCurrentMilliTime];
                }
            }
        }];
#endif
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
    
    NSLog(@"compareBeaconsAndDelegate : %@\n %@\n%@", self.previousVicinityBeacons, self.scannedBeacons, (isEqual?@"same":@"Different"));
   
    if (!isEqual)
    {
        self.previousVicinityBeacons = self.scannedBeacons;
        self.scannedBeacons = [[NSMutableArray alloc] init];
        
        // delegates
        if (self.delegate && [self.delegate respondsToSelector:@selector(didVicinityBeaconsFound:)])
        {
            [self.delegate didVicinityBeaconsFound:self.previousVicinityBeacons];
        }
    }
    else
    {
        [self.delegate didBeaconsFound:self.scannedBeacons];
        self.scannedBeacons = [[NSMutableArray alloc] init];
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
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
    {
        NSLog(@"error : cannot monitoring for class : clbeaconregion");
    }
    
    if (![CLLocationManager isRangingAvailable])
    {
        NSLog(@"error : cannot ranging");
    }
    
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
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    });
    NSLog(@"didStartMonitoringForRegion -- ");
}


- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    NSLog(@"didRangeBeacons : %@", beacons);
    
    if (self.scanMode == ScanModeNormal)
    {
        if (scanningMethod == kScanFor10SecsPerMin)
        {
            if (!bScanReceive)
                return;
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
        NSArray *arrayBeacons = [beacons copy];
        [self.queue addOperationWithBlock:^() {
            long currTime = [self getCurrentMilliTime];
            
            // when change
            for (CLBeacon *beacon in arrayBeacons) {
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
                    for (ScannedBeacon *scannedBeacon in self.scannedBeaconsForNearmeMode) {
                        if ([scannedBeacon.beacon.major intValue] == beaconMajor &&
                            [scannedBeacon.beacon.minor intValue] == beaconMinor)
                        {
                            scannedBeacon.lastScannedTime = currTime;
                            isExist = YES;
                            break;
                        }
                    }
                    
                    if (!isExist)
                    {
                        ScannedBeacon *scannedBeacon = [[ScannedBeacon alloc] init];
                        scannedBeacon.beacon = beacon;
                        scannedBeacon.lastScannedTime = currTime;
                        [self.scannedBeaconsForNearmeMode addObject:scannedBeacon];
                    }
                }
            }
            
            
            // remove timed out beacons --------------------
            NSMutableArray *removeBeacons = [[NSMutableArray alloc] init];
            for (ScannedBeacon *scannedBeacon in self.scannedBeaconsForNearmeMode) {
                if (currTime - scannedBeacon.lastScannedTime > kScanTimout * 1000)
                {
                    [removeBeacons addObject:scannedBeacon];
                }
            }
            
            for (ScannedBeacon *scannedBeacon in removeBeacons) {
                [self.scannedBeaconsForNearmeMode removeObject:scannedBeacon];
            }
            
            // compare two arrays
            BOOL isEqual = YES;
            if (self.prevScannedBeaconsForNearmeMode.count != self.scannedBeaconsForNearmeMode.count)
            {
                isEqual = NO;
            }
            else
            {
                for (ScannedBeacon *scannedBeacon in self.prevScannedBeaconsForNearmeMode) {
                    BOOL isExist = NO;
                    for (ScannedBeacon *currScannedBeacon in self.scannedBeaconsForNearmeMode) {
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
                self.prevScannedBeaconsForNearmeMode = [self.scannedBeaconsForNearmeMode copy];
                NSMutableArray *vicinityBeacons = [[NSMutableArray alloc] init];
                for (ScannedBeacon *scannedBeacon in self.scannedBeaconsForNearmeMode) {
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
                if (self.delegate && currTime - lastDelegateTime > 6 * 1000)
                {
                    NSMutableArray *arrayBeacons = [[NSMutableArray alloc] init];
                    for (ScannedBeacon *scannedBeacon in self.scannedBeaconsForNearmeMode) {
                        [arrayBeacons addObject:scannedBeacon.beacon];
                    }
                    [self.delegate didBeaconsFound:arrayBeacons];
                    lastDelegateTime = [self getCurrentMilliTime];
                }
            }
        }];
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
