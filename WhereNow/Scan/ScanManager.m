//
//  ScanManager.m
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "ScanManager.h"

@interface ScanManager()

@property (retain, nonatomic) CLBeaconRegion *beaconRegion;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL isStarted;

@end

@implementation ScanManager

- (id)init
{
    self = [super init];
    if (self) {
        //
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
    self.isStarted = NO;
    return self;
}

#pragma mark - public functions

- (void)start
{
    if (self.isStarted)
        return;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self initRegion];
    
    self.isStarted = YES;
}

- (void)stop
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
    
    self.isStarted = NO;
}

- (BOOL)isStarted
{
    return self.isStarted;
}

#pragma mark - internal functions
- (void)initRegion {
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:GLOBAL_UUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:HOSPITAL_MAJOR
                                                           identifier:@"com.app.BeaconRegion"];
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


-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    
    // when change
    for (CLBeacon *beacon in beacons) {
        int beaconMajor = [beacon.major integerValue];
        int beaconMinor = [beacon.minor integerValue];
        int rssi = beacon.rssi;
        
        NSLog(@"beacon(%d, %d) : %d", beaconMajor, beaconMinor, rssi);
        
        CLProximity beaconProximity = beacon.proximity;
        
        if (beaconProximity == CLProximityUnknown)
        {
            // not
        }
        
        // delegates
    }
    
    
#if 0
#ifdef USE_TRY
    @try {
#endif
        CLBeacon *beacon;// = [[CLBeacon alloc] init];
        beacon = [beacons firstObject];//[[beacons firstObject] copy];
        
        if (beacons == nil || [beacons count] == 0 || beacon == nil)
        {
            if (beacons == nil)
                NSLog(@"beacons = nil");
            else if ([beacons count] == 0)
                NSLog(@"beacons count = 0");
            else
                NSLog(@"beacon = nil");
        }
        else
        {
            CLProximity beaconProximity = beacon.proximity;
            NSString *beaconUUID = [NSString stringWithFormat:@"%@", beacon.proximityUUID.UUIDString];
            int beaconMajor = [beacon.major intValue];
            int beaconMinor = [beacon.minor intValue];
            
#if ENTER_WHEN_NEAR
            if (beaconProximity == CLProximityUnknown || beaconProximity == CLProximityFar || beaconProximity == CLProximityNear)
#else
                if (beaconProximity == CLProximityUnknown)
#endif
                {
                    NSLog(@"out of range : %d", (int)beaconProximity);
                    
                    animIndex = 0;
                    
                    if (currMajor != -1 && currMinor != -1)
                    {
                        // ------ duplicate checking -----------
                        NSDate *currDate = [NSDate date];
                        
                        BOOL isDuplicated = YES;
                        if (exitTime == nil)
                            isDuplicated = NO;
                        else
                        {
                            NSTimeInterval secs = [currDate timeIntervalSinceDate:exitTime];
                            if (secs < kDuplicateInterval)
                                isDuplicated = YES;
                            else
                                isDuplicated = NO;
                        }
                        exitTime = currDate;
                        
#if ENABLE_RECORDING_OUT
                        User *user = [User currentUser];
                        if (user)
                        {
                            PFObject *event = [PFObject objectWithClassName:@"Events"];
                            event[@"email"] = user.email;
                            event[@"type"] = @"out of range";
                            event[@"uuid"] = beaconUUID;
                            event[@"major"] = [NSString stringWithFormat:@"%d", currMajor];
                            event[@"minior"] = [NSString stringWithFormat:@"%d", currMinor];
                            event[@"localtime"] = [Common date2str:[NSDate date] withFormat:DATETIME_FORMAT];
                            [event saveInBackground];
                        }
                        else
                            NSLog(@"out event not recorded since user is null");
#endif
                        
                        currMajor = currMinor = -1;
                        
                        self.lblStatus.text = @"user exited in a range of beacon";
                        
                        NSLog(@"exited -------------------- \n");
                    }
                    
                }
                else
                {
                    animIndex = (animIndex + 1) % [bluetoothIcons count];
                    
                    if (currMajor != beaconMajor || currMinor != beaconMinor) {
                        
                        NSLog(@"user enterend %d, %d", beaconMajor, beaconMinor);
                        
                        // ------ duplicate checking -----------
                        NSDate *currDate = [NSDate date];
                        
                        BOOL isDuplicated = YES;
                        if (enterTime == nil)
                            isDuplicated = NO;
                        else
                        {
                            NSTimeInterval secs = [currDate timeIntervalSinceDate:enterTime];
                            if (secs < kDuplicateInterval)
                                isDuplicated = YES;
                            else
                                isDuplicated = NO;
                        }
                        enterTime = currDate;
                        
                        // --------
                        User *user = [User currentUser];
                        
                        if (user && !isDuplicated)
                        {
                            PFObject *event = [PFObject objectWithClassName:@"Events"];
                            event[@"email"] = user.email;
                            BOOL isEnter = NO;
                            if (currMajor == -1 && currMinor == -1)
                            {
                                event[@"type"] = @"enter into range";
                                isEnter = YES;
                            }
                            else
                            {
                                event[@"type"] = @"move in range";
                                isEnter = NO;
                            }
                            event[@"uuid"] = beaconUUID;
                            event[@"major"] = [NSString stringWithFormat:@"%d", beaconMajor];
                            event[@"minior"] = [NSString stringWithFormat:@"%d", beaconMinor];
                            event[@"localtime"] = [Common date2str:[NSDate date] withFormat:DATETIME_FORMAT];
                            if (isEnter == NO)
                            {
#if ENABLE_RECORDING_MOVE
                                [event saveInBackground];
#endif
                            }
                            else
                            {
                                [event saveInBackground];
                            }
                        }
                        else
                        {
                            if (user == nil)
                                NSLog(@"enter or move event not recorded since user is null");
                            else
                                NSLog(@"enter or move event not recorded since it is duplicated");
                        }
                        
                        currMajor = beaconMajor;
                        currMinor = beaconMinor;
                        
                        self.lblStatus.text = @"user entered in a range of beacon";
                    }
                }
        }
        
        
        /*
         self.beaconFoundLabel.text = @"Yes";
         self.proximityUUIDLabel.text = beacon.proximityUUID.UUIDString;
         self.majorLabel.text = [NSString stringWithFormat:@"%@", beacon.major];
         self.minorLabel.text = [NSString stringWithFormat:@"%@", beacon.minor];
         self.accuracyLabel.text = [NSString stringWithFormat:@"%f", beacon.accuracy];
         if (beacon.proximity == CLProximityUnknown) {
         self.distanceLabel.text = @"Unknown Proximity";
         } else if (beacon.proximity == CLProximityImmediate) {
         self.distanceLabel.text = @"Immediate";
         } else if (beacon.proximity == CLProximityNear) {
         self.distanceLabel.text = @"Near";
         } else if (beacon.proximity == CLProximityFar) {
         self.distanceLabel.text = @"Far";
         }
         self.rssiLabel.text = [NSString stringWithFormat:@"%i", beacon.rssi];
         */
        
#ifdef USE_TRY
    }
    @catch (NSException *exception) {
        // May return nil if a tracker has not already been initialized with a
        // property ID.
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:[NSString stringWithFormat:@"exception %@:%@", exception.name, exception.reason] withFatal:[NSNumber numberWithBool:NO]] build]];  // isFatal (required). NO indicates non-fatal exception.
    }
    @finally {
        //
    }
#endif
#endif
    
}


@end
