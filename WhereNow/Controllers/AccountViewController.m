//
//  AccountViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 31/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "AccountViewController.h"
#import "UserContext.h"
#import "UIManager.h"
#import "BackgroundTaskManager.h"
#import "ServerManager.h"
#import "DeviceCell.h"
#import "AppContext.h"
#import "AppDelegate.h"

@interface AccountViewController () <DeviceCellDelegate>

@property (nonatomic, retain) NSMutableArray *arrayDevices;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation AccountViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadData
{
    [self.indicator startAnimating];
    self.tableView.tableFooterView.hidden = NO;
    
    [[ServerManager sharedManager] getRegisteredDeviceList:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^(NSArray *arrayDevices) {
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.arrayDevices removeAllObjects];
            for (NSDictionary *info in arrayDevices) {
                NSString *device_token = [info objectForKey:kDeviceListDeviceTokenKey];
                if (device_token == nil)
                    continue;
                if ([device_token isEqual:[AppContext sharedAppContext].cleanDeviceToken])
                    continue;
                [self.arrayDevices addObject:info];
            }
            
            [self.tableView reloadData];
            
            [self.indicator stopAnimating];
            self.tableView.tableFooterView.hidden = YES;
        });
        
    } failure:^(NSString * msg) {
        [self.indicator stopAnimating];
        self.tableView.tableFooterView.hidden = YES;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"accounticon_selected"]];
    
    self.arrayDevices = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCurrentLocationChanged:) name:kCurrentLocationChanged object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.navigationController.navigationBar.barStyle = [UIManager navbarStyle];
    //self.navigationController.navigationBar.tintColor = [UIManager navbarTintColor];
    self.navigationController.navigationBar.titleTextAttributes = [UIManager navbarTitleTextAttributes];
    //self.navigationController.navigationBar.barTintColor = [UIManager navbarBarTintColor];
    
    [self loadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return 2;
    else if (section == 1)
        return 1;
    else if (section == 2)
        return 1;
    else
        return self.arrayDevices.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"INFORMATION";
    else if (section == 1)
        return @"LOGIN";
    else if (section == 2)
        return @"CURRENT LOCATION";
    else if (section == 3)
        return @"REGISTERED DEVICE";
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"usernamecell"];
            UILabel *labelUserName = (UILabel *)[cell viewWithTag:101];
            labelUserName.text = [UserContext sharedUserContext].fullName;
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"passwordcell"];
        }
    }
    else if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"logoutcell"];
        UIButton *btnLogout = (UIButton *)[cell viewWithTag:100];
        [btnLogout removeTarget:self action:@selector(onLogout:) forControlEvents:UIControlEventTouchUpInside];
        [btnLogout addTarget:self action:@selector(onLogout:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (indexPath.section == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"locationcell"];
        UILabel *labelLocation = (UILabel *)[cell viewWithTag:100];
        labelLocation.text = [UserContext sharedUserContext].currentLocation;
    }
    else if (indexPath.section == 3)
    {
        DeviceCell *deviceCell = [tableView dequeueReusableCellWithIdentifier:@"devicecell"];
        NSDictionary *info = [self.arrayDevices objectAtIndex:indexPath.row];
        deviceCell.delegate = self;
        deviceCell.deviceInfo = info;
        cell = deviceCell;
    }
    
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions
- (IBAction)onLogout:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate logout];
}

#pragma mark - DeviceCellDelegate
- (void)didCellRemoved:(DeviceCell *)cell
{
    NSDictionary *info = cell.deviceInfo;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView beginUpdates];
    [self.arrayDevices removeObject:cell.deviceInfo];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    
    
    [[ServerManager sharedManager] userLogout:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId tokenId:info[kDeviceListUserDeviceIdKey] isRemote:YES success:^(NSString *tokenId) {
        //
    } failure:^(NSString * msg) {
        //
    }];
}

#pragma mark - notification
- (void)onCurrentLocationChanged:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}


@end
