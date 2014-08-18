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

static BackgroundTaskManager *_sharedBackgroundTaskManager = nil;

@interface BackgroundTaskManager ()

@property (nonatomic, strong) NSMutableArray *arrayVicinityBeacons;

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
    return self;
}

- (void)startScanning
{
    [self.scanManager start];
}

- (void)stopScanning
{
    [self.scanManager stop];
}

- (NSMutableArray *)nearmeBeacons
{
    return self.arrayVicinityBeacons;
}

#pragma mark ScanManagerDelegate
- (void)vicinityBeaconsFound:(NSMutableArray *)arrayBeacons
{
    self.arrayVicinityBeacons = arrayBeacons;
    
    [self requestLocationInfo:self.arrayVicinityBeacons complete:^() {
        //
    }];
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kBackgroundUpdateLocationInfoNotification object:nil userInfo:nil];
}

#pragma mark Request nearme generics/equipments
- (void)requestLocationInfo:(NSMutableArray *)arrayBeacons complete:(void (^)())complete
{
    // send request in background
    [[ServerManager sharedManager] getCurrLocation:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId arrayBeacons:arrayBeacons success:^(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments) {
        
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

@end
