//
//  LocatingManager.m
//  WhereNow
//
//  Created by Xiaoxue Han on 03/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "LocatingManager.h"
#import "ModelManager.h"
#import "ServerManager.h"
#import "UserContext.h"
#import "AppContext.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

static LocatingManager *_sharedLocatingManager = nil;

@implementation LocatingManager

+ (LocatingManager *)sharedInstance
{
    if (_sharedLocatingManager == nil)
        _sharedLocatingManager = [[LocatingManager alloc] init];
    return _sharedLocatingManager;
}

- (id)init
{
    self = [super init];
    self.arrayLocatingEquipments = [[ModelManager sharedManager] retrieveLocatingEquipments];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLocatingChanged:) name:kLocatingChanged object:nil];
    return self;
}

- (void)locatingEquipment:(Equipment *)equipment
{
    NSString *utoken = [AppContext sharedAppContext].cleanDeviceToken;
    equipment.islocating = @(YES);
    [[ServerManager sharedManager] createEquipmentWatch:@[equipment.equipment_id] token:utoken sessionId:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^() {
        NSLog(@"createEquipmentWatch success : %@", equipment.equipment_id);
    } failure:^(NSString *msg) {
        NSLog(@"createEquipmentWatch failure : %@", equipment.equipment_id);
    }];
    
    [[ModelManager sharedManager] saveContext];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocatingChanged object:nil];
}

- (void)cancelLocatingEquipment:(Equipment *)equipment
{
    NSString *utoken = [AppContext sharedAppContext].cleanDeviceToken;
    equipment.islocating = @(NO);
    [[ServerManager sharedManager] cancelEquipmentWatch:@[equipment.equipment_id] token:utoken sessionId:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^() {
        NSLog(@"cancelEquipmentWatch success : %@", equipment.equipment_id);
    } failure:^(NSString *msg) {
        NSLog(@"cancelEquipmentWatch failure : %@", equipment.equipment_id);
    }];
    
    [[ModelManager sharedManager] saveContext];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocatingChanged object:nil];
}

- (void)onLocatingGeneric:(Generic *)generic
{
    NSMutableArray *arrayEquipments = [[ModelManager sharedManager] equipmentsForGeneric:generic withBeacon:YES];
    int nLocating = 0;
    int nUnlocating = 0;
    for (Equipment *equipment in arrayEquipments) {
        if ([equipment.islocating boolValue])
            nLocating++;
        else
            nUnlocating++;
    }
    
    NSString *utoken = [AppContext sharedAppContext].cleanDeviceToken;
    
    if (nLocating == 0)
    {
        NSMutableArray *arrayIds = [[NSMutableArray alloc] init];
        for (Equipment *equipment in arrayEquipments) {
            if (![equipment.islocating boolValue])
                [arrayIds addObject:equipment.equipment_id];
            equipment.islocating = @(YES);
        }
        
        if (arrayIds.count > 0)
        {
            [[ServerManager sharedManager] createEquipmentWatch:arrayIds token:utoken sessionId:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^() {
                NSLog(@"createEquipmentWatch success : %@", arrayIds);
            } failure:^(NSString *msg) {
                NSLog(@"createEquipmentWatch failure : %@", arrayIds);
            }];
        }
    }
    else if (nUnlocating == 0)
    {
        NSMutableArray *arrayIds = [[NSMutableArray alloc] init];
        for (Equipment *equipment in arrayEquipments) {
            if ([equipment.islocating boolValue])
                [arrayIds addObject:equipment.equipment_id];
            equipment.islocating = @(NO);
        }
        
        if (arrayIds.count > 0)
        {
            [[ServerManager sharedManager] cancelEquipmentWatch:arrayIds token:utoken sessionId:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^() {
                NSLog(@"cancelEquipmentWatch success : %@", arrayIds);
            } failure:^(NSString *msg) {
                NSLog(@"cancelEquipmentWatch failure : %@", arrayIds);
            }];
        }
    }
    else
    {
        NSMutableArray *arrayIds = [[NSMutableArray alloc] init];
        for (Equipment *equipment in arrayEquipments) {
            if (![equipment.islocating boolValue])
                [arrayIds addObject:equipment.equipment_id];
            equipment.islocating = @(YES);
        }
        
        if (arrayIds.count > 0)
        {
            [[ServerManager sharedManager] createEquipmentWatch:arrayIds token:utoken sessionId:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^() {
                NSLog(@"createEquipmentWatch success : %@", arrayIds);
            } failure:^(NSString *msg) {
                NSLog(@"createEquipmentWatch failure : %@", arrayIds);
            }];
        }
    }
    
    [[ModelManager sharedManager] saveContext];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocatingChanged object:nil];
}

- (void)locatingGeneric:(Generic *)generic
{
    //
}

- (void)cancelLocatingGeneric:(Generic *)generic
{
    //
}

- (void)checkLocatingBeacons:(NSMutableArray *)arrayBeacons
{
    NSMutableArray *arrayFoundEquipments = [[NSMutableArray alloc] init];
    // check beacons for locating equipments
    for (CLBeacon *beacon in arrayBeacons) {
        for (Equipment *equipment in self.arrayLocatingEquipments) {
            if ([beacon.proximityUUID.UUIDString isEqualToString:equipment.uuid] &&
                [beacon.major intValue] == [equipment.major intValue] &&
                [beacon.minor intValue] == [equipment.minor intValue])
            {
                if (![arrayFoundEquipments containsObject:equipment])
                    [arrayFoundEquipments addObject:equipment];
            }
        }
    }
    
    // found beacons
    if (arrayFoundEquipments.count > 0)
    {
        // locating off
        NSMutableArray *arrayEquipmentIds = [[NSMutableArray alloc] init];
        for (Equipment *equipment in arrayFoundEquipments) {
            equipment.islocating = @(NO);
            [arrayEquipmentIds addObject:equipment.equipment_id];
        }
        [[ModelManager sharedManager] saveContext];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocatingChanged object:nil];
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate foundEquipments:arrayFoundEquipments];
        
        // cancel watching
        NSString *utoken = [AppContext sharedAppContext].cleanDeviceToken;
        [[ServerManager sharedManager] cancelEquipmentWatch:arrayEquipmentIds token:utoken sessionId:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^() {
            NSLog(@"cancelEquipmentWatch success : %@", arrayEquipmentIds);
        } failure:^(NSString *msg) {
            NSLog(@"cancelEquipmentWatch failure : %@", arrayEquipmentIds);
        }];
    }

}

- (void)onLocatingChanged:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        // reload locating equipments
        self.arrayLocatingEquipments = [[ModelManager sharedManager] retrieveLocatingEquipments];
    });
}

@end
