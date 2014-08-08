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

@interface BackgroundTaskManager : NSObject <ScanManagerDelegate>

+ (BackgroundTaskManager *)sharedManager;

@property (nonatomic, retain) ScanManager *scanManager;

- (void)startScanning;
- (void)stopScanning;

@end
