//
//  HistoryViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 02/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "HistoryViewController.h"
#import "EquipmentTabBarController.h"
#import "UIManager.h"
#import "ModelManager.h"
#import "ServerManager.h"
#import "BackgroundTaskManager.h"

#import <snfsdk/snfsdk.h>

@interface HistoryViewController () <UIActionSheetDelegate, LeDeviceManagerDelegate, LeSnfDeviceDelegate>
{
    UIBarButtonItem *_backButton;
    Equipment *_equipment;
    LeDeviceManager *_mgr;
    NSTimer *_timerForAlert;
}

@property (nonatomic, strong) NSMutableArray *arrayMovements;
@property (nonatomic, strong) NSMutableDictionary *groupedMovements;
@property (nonatomic, strong) NSMutableArray *groupedDates;
@property (nonatomic, strong) MovementCount *movementCount;

@property (nonatomic, weak) IBOutlet UIImageView *ivImg1;
@property (nonatomic, weak) IBOutlet UIImageView *ivImg2;
@property (strong, nonatomic) IBOutlet UITableView *tableView;



@end

@implementation HistoryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //[self.navigationController.tabBarItem setImage:[UIImage imageNamed:@"historyicon"]];
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"historyicon_selected"]];
    
    // back button
    _backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backicon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = _backButton;
    
    UIBarButtonItem *_menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuicon"] style:UIBarButtonItemStylePlain target:self action:@selector(onMenu:)];
    self.navigationItem.rightBarButtonItem = _menuButton;
    
    EquipmentTabBarController *tabbarController = (EquipmentTabBarController *)self.tabBarController;
    _equipment = tabbarController.equipment;
    if (_equipment != nil)
    {
        self.navigationItem.title = [NSString stringWithFormat:@"%@-%@", _equipment.manufacturer_name, _equipment.model_name_no];
        
        self.arrayMovements = [[ModelManager sharedManager] equipmovementsForEquipment:_equipment];
        
        self.groupedMovements = [[NSMutableDictionary alloc] init];
        self.groupedDates = [[NSMutableArray alloc] init];
        
        // group by date
        for (EquipMovement *movement in self.arrayMovements) {
            NSMutableArray *array = [self.groupedMovements objectForKey:movement.date];
            if (array == nil)
            {
                array = [[NSMutableArray alloc] init];
                [self.groupedDates addObject:movement.date];
            }
            [array addObject:movement];
            [self.groupedMovements setObject:array forKey:movement.date];
        }
    }
    else
    {
        self.arrayMovements = [[NSMutableArray alloc] init];
        self.groupedMovements = [[NSMutableDictionary alloc] init];
        self.groupedDates = [[NSMutableArray alloc] init];
    }
    
    NSArray *arrayMovementCount = [[ModelManager sharedManager] retrieveMovementCountForEquipment:_equipment];
    if (arrayMovementCount != nil && arrayMovementCount.count > 0)
        self.movementCount = [arrayMovementCount objectAtIndex:0];
    else
        self.movementCount = nil;
    
    // set images
    [[ServerManager sharedManager] setImageContent:self.ivImg1 urlString:_equipment.equipment_file_location];
    [[ServerManager sharedManager] setImageContent:self.ivImg2 urlString:_equipment.model_file_location];
    
    // set empty view to footer view
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;
    
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
}

#pragma mark - Table view data source

static UITableViewCell *_prototypeMovementsCell = nil;
static UITableViewCell *_prototypeHistoryCell = nil;

- (UITableViewCell *)prototypeMovementsCell
{
    if (_prototypeMovementsCell == nil)
        _prototypeMovementsCell = [self.tableView dequeueReusableCellWithIdentifier:@"movementscell"];
    return _prototypeMovementsCell;
}

- (UITableViewCell *)prototypeHistoryCell
{
    if (_prototypeHistoryCell == nil)
        _prototypeHistoryCell = [self.tableView dequeueReusableCellWithIdentifier:@"historycell"];
    return _prototypeHistoryCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1 + self.groupedDates.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 27;
    else
        return 27;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 3, tableView.frame.size.width, 22)];
    [label setFont:[UIFont boldSystemFontOfSize:17]];
    NSString *string = @"Movements";
    if (section > 0)
    {
        string = [self.groupedDates objectAtIndex:section - 1];
        
        NSDate *today = [NSDate date];
        NSDate *yesterday = [today dateByAddingTimeInterval:- 60 * 60 * 24];
        
        if ([string isEqualToString:[Common date2str:today withFormat:DATE_FORMAT]])
            string = @"Today";
        else if ([string isEqualToString:[Common date2str:yesterday withFormat:DATE_FORMAT]])
            string = @"Yesterday";
    }
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]];
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return 1;
    else
    {
        NSString *date = [self.groupedDates objectAtIndex:section - 1];
        NSArray *array = [self.groupedMovements objectForKey:date];
        return array.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
        return [self prototypeMovementsCell].bounds.size.height;
    else
        return [self prototypeHistoryCell].bounds.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0)
        cell = [tableView dequeueReusableCellWithIdentifier:@"movementscell"];
    else
    {
        NSString *date = [self.groupedDates objectAtIndex:indexPath.section - 1];
        NSArray *array = [self.groupedMovements objectForKey:date];
        
        int index = indexPath.row;
        EquipMovement *movement = [array objectAtIndex:index];
        cell = [tableView dequeueReusableCellWithIdentifier:@"historycell"];
        UILabel *lblLevel = (UILabel *)[cell viewWithTag:100];
        UILabel *lblLocation = (UILabel *)[cell viewWithTag:101];
        UILabel *stay_time1 = (UILabel *)[cell viewWithTag:102];
        UILabel *stay_time2 = (UILabel *)[cell viewWithTag:103];
        
        lblLocation.text = movement.location_name;
        stay_time1.text = [NSString stringWithFormat:@"arrived at %@", movement.time];
        stay_time2.text = [NSString stringWithFormat:@"at location for %@", movement.stay_time];
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

#pragma mark - Back button
- (void)onBack:(id)sender
{
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Menu button
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
        [self onPageDevice];
    }
    else if (buttonIndex == 1){
        // Report for Service
    }
}

- (void)onPageDevice
{
    [[BackgroundTaskManager sharedManager] stopScanning];
    
    //
    _mgr = [[LeDeviceManager alloc] initWithSupportedDevices:@[[LeSnfDevice class]] delegate:self];
    [_mgr startScan];
}

#pragma mark - LeDeviceManagerdelegate
- (void)leDeviceManager:(LeDeviceManager *)mgr didAddNewDevice:(LeDevice *)dev
{
    //
}

- (void)retrieveStoredDeviceUUIDsForLeDeviceManager:(LeDeviceManager *)mgr
{
    //
}

- (void)leDeviceManager:(LeDeviceManager *)mgr valueForDeviceUUID:(CFUUIDRef)uuid key:(NSString *)key
{
    //
}

- (void)leDeviceManager:(LeDeviceManager *)mgr setValue:(id)value forDeviceUUID:(CFUUIDRef)uuid key:(NSString *)key
{
    //
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
    for (id key in [advData allKeys]) {
        NSObject *obj = [advData objectForKey:key];
    }
    
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
