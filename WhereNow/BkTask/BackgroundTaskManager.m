//
//  BackgroundTaskManager.m
//  WhereNow
//
//  Created by Xiaoxue Han on 08/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "BackgroundTaskManager.h"
#import "ServerManager.h"
#import "UserContext.h"
#import "ModelManager.h"
#import "AppDelegate.h"
#import "AppContext.h"
#import "LocatingManager.h"

#define kPeriodOfStickBeaconMode        60 * 3

static BackgroundTaskManager *_sharedBackgroundTaskManager = nil;

@interface BackgroundTaskManager ()

@property (nonatomic, strong) NSMutableArray *arrayVicinityBeacons;
@property (nonatomic) BOOL stickBeaconMode;
@property (nonatomic, retain) NSTimer *timerForStickBeaconMode;

@end

@implementation BackgroundTaskManager

+ (BackgroundTaskManager *)sharedManager
{
    if (_sharedBackgroundTaskManager == nil)
        _sharedBackgroundTaskManager = [[BackgroundTaskManager alloc] init];
    return _sharedBackgroundTaskManager;
}

- (id)init
{
    self = [super init];

    self.arrayVicinityBeacons = [[NSMutableArray alloc] init];
    
    self.arrayNearmeGenerics = [[NSMutableArray alloc] init];
    self.arrayVicinityEquipments = [[NSMutableArray alloc] init];
    self.arrayLocationEquipments = [[NSMutableArray alloc] init];
    
    self.scanManager = [[ScanManager alloc] initWithDelegate:self];
    self.stickBeaconManager = [StickerManager sharedManager];
    self.stickBeaconMode = NO;

    return self;
}

- (void)startScanning
{
    [self.scanManager start];
    //[self.stickBeaconManager startDiscover];
    
}

- (void)stopScanning
{
    [self.scanManager stop];
    if (self.stickBeaconMode)
        [self.stickBeaconManager stopDiscover];
}

- (NSMutableArray *)nearmeBeacons
{
    return self.arrayVicinityBeacons;
}

#pragma mark ScanManagerDelegate
- (void)didVicinityBeaconsFound:(NSMutableArray *)arrayBeacons
{
    self.arrayVicinityBeacons = arrayBeacons;
    
    [self requestLocationInfo:self.arrayVicinityBeacons complete:^() {
        // post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kBackgroundUpdateLocationInfoNotification object:nil userInfo:nil];
    }];
    
    [self checkLocatingBeacons:self.arrayVicinityBeacons];
}

- (void)didBeaconsFound:(NSMutableArray *)arrayBeacons
{
    [self checkLocatingBeacons:arrayBeacons];
}

- (void)checkLocatingBeacons:(NSMutableArray *)arrayBeacons
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        [[LocatingManager sharedInstance] checkLocatingBeacons:arrayBeacons];
    });
}

#pragma mark Request nearme generics/equipments
- (void)requestLocationInfo:(NSMutableArray *)arrayBeacons complete:(void (^)())complete
{
    // send request in background
    [[ServerManager sharedManager] getCurrLocationV2:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId arrayBeacons:arrayBeacons success:^(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments) {
        
        self.arrayNearmeGenerics = arrayGenerics;
        self.arrayVicinityEquipments = arrayVicinityEquipments;
        self.arrayLocationEquipments = arrayLocationEquipments;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^() {
            complete();
        }];
        
    } failure:^(NSString *msg) {
        complete();
    }];
}

- (void)changeToStickBeaconMode
{
    self.stickBeaconMode = YES;
    [self.scanManager stop];
    
    [self.stickBeaconManager startDiscover];
    self.timerForStickBeaconMode = [NSTimer scheduledTimerWithTimeInterval:kPeriodOfStickBeaconMode target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)cancelStickBeaconMode
{
    if (self.timerForStickBeaconMode)
    {
        [self.timerForStickBeaconMode invalidate];
        self.timerForStickBeaconMode = nil;
    }
    
    [self.stickBeaconManager stopDiscover];
    self.stickBeaconMode = NO;
    [self.scanManager start];
}

- (void)onTimer:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self cancelStickBeaconMode];
    });
}

@end
