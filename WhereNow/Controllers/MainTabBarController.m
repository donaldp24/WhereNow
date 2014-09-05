//
//  MainTabBarController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "MainTabBarController.h"
#import "ServerManager.h"
#import "UserContext.h"
#import "ScanManager.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

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
    
    self.navigationController.navigationBarHidden = YES;
    
    [[ServerManager sharedManager] getGenerics:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^() {
    } failure: ^(NSString *msg) {
        NSLog(@"Data request failed : %@", msg);
    }];
    
    if([ScanManager locationServiceEnabled]){
        
        NSLog(@"Location Services Enabled");
        
        if(![ScanManager permissionEnabled]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
                                               message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        NSLog(@"Location Services Disabled");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                        message:@"To enable, please go to Settings and turn on Location Service."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

@end
