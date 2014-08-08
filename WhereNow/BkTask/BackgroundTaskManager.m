//
//  BackgroundTaskManager.m
//  WhereNow
//
//  Created by Xiaoxue Han on 08/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "BackgroundTaskManager.h"
#import "ServerManager.h"

static BackgroundTaskManager *_sharedBackgroundTaskManager = nil;

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

- (void)vicinityBeacons:(NSMutableArray *)arrayBeacons
{
    // send request in background
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kBackgroundUpdateLocationInfoNotification object:nil userInfo:nil];
}

@end
