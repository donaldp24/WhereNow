//
//  EquipmentTabBarController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 02/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "EquipmentTabBarController.h"
#import "DetailBaseTableViewController.h"
#import "BackgroundTaskManager.h"

#import <snfsdk/snfsdk.h>

@interface EquipmentTabBarController () <UIActionSheetDelegate, LeDeviceManagerDelegate, LeSnfDeviceDelegate>
{
    LeDeviceManager *_mgr;
}

@end

@implementation EquipmentTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for (UINavigationController *nav in self.viewControllers) {
        DetailBaseTableViewController *vc = (DetailBaseTableViewController *)[[nav viewControllers] objectAtIndex:0];
        vc.delegate = self;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - menu delegate
- (void)onMenu:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  @"Page Device",
                                  @"Report for Service",
                                  nil];
    //    [actionSheet setTintColor:[UIColor darkGrayColor]];
    
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // Page Device
        [self onPageDevice:self.equipment];
    }
    else if (buttonIndex == 1){
        // Report for Service
        [self onReportForService:self.equipment];
    }
}

- (void)onPageDevice:(Equipment *)equipment
{
//    [[BackgroundTaskManager sharedManager] stopScanning];
//    
//    //
//    _mgr = [[LeDeviceManager alloc] initWithSupportedDevices:@[[LeSnfDevice class]] delegate:self];
//    [_mgr startScan];
}

- (void)onReportForService:(Equipment *)equipment
{
    //
}

- (void)onBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - LeDeviceManagerdelegate
- (void)leDeviceManager:(LeDeviceManager *)mgr didAddNewDevice:(LeDevice *)dev
{
    //
}

- (void)leDeviceManager:(LeDeviceManager *)mgr setValue:(id)value forDeviceUUID:(CFUUIDRef)uuid key:(NSString *)key
{
    //
}

- (id)leDeviceManager:(LeDeviceManager *)mgr valueForDeviceUUID:(CFUUIDRef)uuid key:(NSString *)key
{
    return nil;
}

- (NSArray *)retrieveStoredDeviceUUIDsForLeDeviceManager:(LeDeviceManager *)mgr
{
    return nil;
}

- (BOOL)leDeviceManager:(LeDeviceManager *)mgr willAddNewDeviceForPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary *)advData
{
    for (id key in [advData allKeys]) {
        NSObject *obj = [advData objectForKey:key];
        if (obj && [(NSString *)key isEqualToString:@"kCBAdvDataServiceUUIDs"]) {
            NSArray *arrayServices = (NSArray *)obj;
            for (CBUUID *uuid in arrayServices) {
                NSLog(@"Service uuid - %@", uuid.UUIDString);
            }
        }
    }
    return YES;
}

- (Class)leDeviceManager:(LeDeviceManager *)mgr didDiscoverUnknownPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary *)advData RSSI:(NSNumber *)RSSI
{
    return nil;
}

- (void)leDeviceManager:(LeDeviceManager *)mgr didDiscoverDevice:(LeDevice *)dev advertisementData:(NSDictionary *)advData RSSI:(NSNumber *)RSSI
{
    // check dev is the device to that we have to connect.
    
    NSLog(@"dev - %@", dev.name);
    LeSnfDevice *snfDev = (LeSnfDevice *)dev;
    if (snfDev.state == LE_DEVICE_STATE_DISCONNECTED) {
        NSLog(@"connecting to %@ ", dev.name);
        snfDev.delegate = self;
        [snfDev connect];
    }
    
}


#pragma mark - LeSnfDeviceDelegate
/*
 called when the connection state of a device changes.
 */
- (void)leSnfDevice:(LeSnfDevice *)dev didChangeState:(int)state
{
    if (state == LE_DEVICE_STATE_CONNECTED)
    {
        NSLog(@"device connected");
        
        // enable alert sound
        [dev enableAlertSound:YES light:YES];
    }
    else if (state == LE_DEVICE_STATE_DISCONNECTED)
    {
        NSLog(@"device disconnected ");
    }
}

/*
 called when a broadcast from the device is received.
 */
- (void)didDiscoverLeSnfDevice:(LeSnfDevice *)dev
{
    NSLog(@"didDiscoverLeSnfDevice : %@", dev.name);
}

- (void)didEnableAlertForLeSnfDevice:(LeSnfDevice *)dev success:(BOOL)success
{
    NSLog(@"didEnableAlertForLeSnfDevice : %@ - %@", dev.name, (success)?@"success":@"failed");
    
    [dev disconnect];
    [_mgr stopScan];
    _mgr = nil;
}



@end
