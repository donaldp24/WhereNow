//
//  AppDelegate.m
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "AppDelegate.h"
#import "UserContext.h"
#import "AppContext.h"
#import "ModelManager.h"
#import "ServerManager.h"
#import "ResponseParseStrategy.h"
#import "BackgroundTaskManager.h"

#import "TriggeredAlertsTableViewController.h"
#import "FoundEquipmentTableViewController.h"

@interface AppDelegate () <UIAlertViewDelegate, TriggeredAlertsTableViewControllerDelegate, FoundEquipmentTableViewControllerDelegate>

@property (nonatomic) BOOL bShownTriggeredAlerts;
@property (nonatomic) BOOL bShownFoundEquipment;
@property (nonatomic, retain) UIAlertView *alertViewTriggeredAlerts;
@property (nonatomic, retain) UIAlertView *alertViewFoundEquipments;
@property (nonatomic, retain) UIAlertView *alertViewElse;
@property (nonatomic, retain) NSMutableArray *arrayFoundEquipments;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[ModelManager sharedManager] initModelManager];
    [ServerManager sharedManager].parser = [ResponseParseStrategy sharedParseStrategy];
    
    // have to start scanning after logged in
    //[[BackgroundTaskManager sharedManager] startScanning];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
#else
    // register push notification
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
#endif
    
    if (launchOptions != nil) {
        // Launched from push notification
        NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSLog(@"Launched from push notification : %@", notification);
        
        NSString *alert_type = [notification objectForKey:@"alert_type"];
        if (alert_type != nil && [alert_type isEqualToString:@"alert"])
        {
            NSObject *obj = [notification objectForKey:@"alert_id"];
            if (obj != nil)
            {
                int alert_id = [(NSNumber *)obj intValue];
                [[ModelManager sharedManager] addTriggeredAlert:alert_id];
            }

            [self performSelectorOnMainThread:@selector(showTriggeredAlerts) withObject:nil waitUntilDone:NO];
        }

    }
    
    return YES;
}

- (void)showTriggeredAlerts
{
    if (self.bShownTriggeredAlerts)
        return;
    
    self.bShownTriggeredAlerts = YES;
    
    // show
    UINavigationController *vcNav = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"TriggeredNavViewController"];
    TriggeredAlertsTableViewController *vc = [vcNav.viewControllers objectAtIndex:0];
    vc.delegate = self;
    
    [self.window.rootViewController presentViewController:vcNav animated:YES completion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // save contex
    [[ModelManager sharedManager] saveContext];
    
    // cancel stick beacon mode
    [[BackgroundTaskManager sharedManager] cancelStickBeaconMode];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // request data
    if ([UserContext sharedUserContext].isLoggedIn)
    {
        //[ServerManager sharedManager]
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // save context
    [[ModelManager sharedManager] saveContext];
}

#pragma mark - APNS
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
#if TARGET_IPHONE_SIMULATOR
    
#else

    NSString* cleanDeviceToken = [[[[deviceToken description]
                                    stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                   stringByReplacingOccurrencesOfString: @">" withString: @""]
                                  stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    [AppContext sharedAppContext].cleanDeviceToken = cleanDeviceToken;
    
    NSLog(@"Registered for remote notifications  %@", cleanDeviceToken);
    
    if ([UserContext sharedUserContext].isLoggedIn)
        [[ServerManager sharedManager] updateDeviceToken:cleanDeviceToken userId:[UserContext sharedUserContext].userId success:^(NSString *tokenId) {
            NSLog(@"device token registered : %@", cleanDeviceToken);
        } failure:^(NSString *msg) {
            NSLog(@"device token registering failed - %@", msg);
        }];
    

#endif
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification ---------- \n%@", userInfo);
    
    NSString *alert_type = [userInfo objectForKey:@"alert_type"];
    if (alert_type != nil &&
        [alert_type isEqualToString:@"alert"])
    {
        NSObject *obj = [userInfo objectForKey:@"alert_id"];
        if (obj != nil)
        {
            int alert_id = [(NSNumber *)obj intValue];
            [[ModelManager sharedManager] addTriggeredAlert:alert_id];
        }
        
        
        if (application.applicationState == UIApplicationStateActive) {
            // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
            if (!self.bShownTriggeredAlerts)
            {
                //if (self.alertViewFoundEquipments != nil)
                //    [self.alertViewFoundEquipments dismissWithClickedButtonIndex:0 animated:YES];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                self.alertViewTriggeredAlerts = alertView;
                [alertView show];
            }
        }
        else {
            NSLog(@"application is not active ---");
            
            //[self showTriggeredAlerts];
        }
    }
    else
    {
        if (application.applicationState == UIApplicationStateActive) {
            if (self.alertViewElse)
                [self.alertViewElse dismissWithClickedButtonIndex:0 animated:NO];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            self.alertViewElse = alertView;
            [alertView show];
        }
        else {
            NSLog(@"application is not active ---");
            
            //[self showTriggeredAlerts];
        }
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if (error != nil)
        NSLog(@"registering for remote notification failed : %@", [error description]);
    else
        NSLog(@"registering for remote notification failed");
}

#pragma mark - alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.alertViewTriggeredAlerts)
        [self showTriggeredAlerts];
    else if (alertView == self.alertViewFoundEquipments)
        [self showFoundEquipments];
    else if (alertView == self.alertViewElse)
        self.alertViewElse = nil;
}

#pragma mark - TriggeredAlertsDelegate
- (void)didTriggeredAlertsDone:(TriggeredAlertsTableViewController *)vc
{
    [vc.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    self.bShownTriggeredAlerts = NO;
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // reset badge count
    NSString *token = [AppContext sharedAppContext].cleanDeviceToken;
    if (token != nil && token.length > 0)
    {
        [[ServerManager sharedManager] resetBadgeCountWithToken:token success:^{
            NSLog(@"resetbadge success!");
        } failure:^(NSString *msg) {
            NSLog(@"reset badge failed : %@", msg);
        }];
    }
}

#pragma mark - found equipments
- (void)foundEquipments:(NSMutableArray *)arrayFoundEquipments
{
    if (arrayFoundEquipments.count == 0)
        return;
    
    Equipment *firstEquipment = [arrayFoundEquipments objectAtIndex:0];
    NSString *equipmentNames = [NSString stringWithFormat:@"%@:%@", firstEquipment.model_name_no, firstEquipment.serial_no];
    for (int i = 1; i < arrayFoundEquipments.count; i++) {
        Equipment *equipment = [arrayFoundEquipments objectAtIndex:i];
        equipmentNames = [NSString stringWithFormat:@"%@, %@:%@", equipmentNames, equipment.model_name_no, equipment.serial_no];
    }
    
    NSString *msg = [NSString stringWithFormat:@"You are near by equipment %@!", equipmentNames];
    
    self.arrayFoundEquipments = [[NSMutableArray alloc] initWithArray:arrayFoundEquipments];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        if (!self.bShownFoundEquipment)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            self.alertViewFoundEquipments = alertView;
            [alertView show];
        }
    }
    else {
        NSLog(@"application is not active ---");
        
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        notification.repeatInterval = NSDayCalendarUnit;
        [notification setAlertBody:msg];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
        [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    }

}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
    if (!self.bShownFoundEquipment)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:notification.alertBody
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        self.alertViewFoundEquipments = alertView;
        [alertView show];
    }

}

- (void)showFoundEquipments
{
    if (self.bShownFoundEquipment)
        return;
    
    self.bShownFoundEquipment = YES;
    
    // show
    UINavigationController *vcNav = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"FoundEquipmentNavViewController"];
    FoundEquipmentTableViewController *vc = [vcNav.viewControllers objectAtIndex:0];
    vc.arrayEquipments = self.arrayFoundEquipments;
    vc.delegate = self;
    
    [self.window.rootViewController presentViewController:vcNav animated:YES completion:nil];
}

#pragma mark - FoundEquipmentTableViewControllerDelegate
- (void)didFoundEquipmentDone:(FoundEquipmentTableViewController *)vc
{
    [vc dismissViewControllerAnimated:YES completion:nil];
    self.bShownFoundEquipment = NO;
}




@end
