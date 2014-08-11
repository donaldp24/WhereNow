//
//  AlertsViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 02/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "AlertsViewController.h"
#import "EquipmentTabBarController.h"
#import "UIManager.h"
#import "ModelManager.h"

@interface AlertsViewController () <UIActionSheetDelegate>
{
    UIBarButtonItem *_backButton;
    Equipment *_equipment;
}

@property (nonatomic, weak) IBOutlet UIImageView *ivImg1;
@property (nonatomic, weak) IBOutlet UIImageView *ivImg2;

@property (nonatomic, strong) NSMutableArray *arrayAlerts;
@property (nonatomic, strong) NSMutableDictionary *groupedAlerts;
@property (nonatomic, strong) NSMutableArray *arrayTypes;

@end

@implementation AlertsViewController

- (void)loadData
{
    self.arrayAlerts = [[ModelManager sharedManager] retrieveAlerts];
    
    if (self.arrayAlerts.count == 0)
    {
        NSManagedObjectContext *managedObjectContext = [ModelManager sharedManager].managedObjectContext;
        Alert *alert = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Alert"
                        inManagedObjectContext:managedObjectContext];
        
        alert.alert_type = @"Current Alerts";
        alert.location_level = @"Level 1";
        alert.location_name = @"Radiology";
        alert.note1 = @"exceeds time limit";
        alert.note2 = @"return to Level 3 Storeroom";
        
        [self.arrayAlerts addObject:alert];
        
        alert = [NSEntityDescription
                 insertNewObjectForEntityForName:@"Alert"
                 inManagedObjectContext:managedObjectContext];
        alert.alert_type = @"Time Alerts";
        alert.location_level = @"Level 1";
        alert.location_name = @"Radiology";
        alert.note1 = @"alerts after 1 day";
        alert.note2 = @"alerts 4 users";
        
        [self.arrayAlerts addObject:alert];

        alert = [NSEntityDescription
                 insertNewObjectForEntityForName:@"Alert"
                 inManagedObjectContext:managedObjectContext];
        alert.alert_type = @"Time Alerts";
        alert.location_level = @"";
        alert.location_name = @"Any location";
        alert.note1 = @"alerts after 2 day";
        alert.note2 = @"alerts 1 users";
        
        [self.arrayAlerts addObject:alert];
        
        alert = [NSEntityDescription
                 insertNewObjectForEntityForName:@"Alert"
                 inManagedObjectContext:managedObjectContext];
        alert.alert_type = @"Time Alerts";
        alert.location_level = @"Level G";
        alert.location_name = @"Cafe";
        alert.note1 = @"alerts after 2 hours";
        alert.note2 = @"alerts 4 users";
        
        [self.arrayAlerts addObject:alert];
    }
    
    self.groupedAlerts = [[NSMutableDictionary alloc] init];
    self.arrayTypes = [[NSMutableArray alloc] init];
    
    for (Alert *alert in self.arrayAlerts) {
        NSMutableArray *arrayGroupAlerts = [self.groupedAlerts objectForKey:alert.alert_type];
        if (arrayGroupAlerts == nil)
        {
            arrayGroupAlerts = [[NSMutableArray alloc] init];
            [self.arrayTypes addObject:alert.alert_type];
        }
        [arrayGroupAlerts addObject:alert];
        [self.groupedAlerts setObject:arrayGroupAlerts forKey:alert.alert_type];
        
    }
}

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
    
    //[self.navigationController.tabBarItem setImage:[UIImage imageNamed:@"alerticon"]];
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"alerticon_selected"]];
    
    // back button
    _backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backicon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = _backButton;
    
    UIBarButtonItem *_menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuicon"] style:UIBarButtonItemStylePlain target:self action:@selector(onMenu:)];
    self.navigationItem.rightBarButtonItem = _menuButton;
    
    EquipmentTabBarController *tabbarController = (EquipmentTabBarController *)self.tabBarController;
    _equipment = tabbarController.equipment;
    if (_equipment != nil)
        self.navigationItem.title = [NSString stringWithFormat:@"%@-%@", _equipment.manufacturer_name, _equipment.model_name_no];
    
    [self loadData];
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

static UITableViewCell *_prototypeAlertCell = nil;

- (UITableViewCell *)prototypeAlertCell
{
    if (_prototypeAlertCell == nil)
        _prototypeAlertCell = [self.tableView dequeueReusableCellWithIdentifier:@"alertcell"];
    return _prototypeAlertCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.arrayTypes.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 27;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
    
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 3, 150, 22)];
    [label setFont:[UIFont boldSystemFontOfSize:17]];
    
    // count label
    UILabel *labelCount = [[UILabel alloc] initWithFrame:CGRectMake(170, 3, 130, 22)];
    [labelCount setFont:[UIFont boldSystemFontOfSize:15]];
    [labelCount setTextAlignment:NSTextAlignmentRight];
    [labelCount setTextColor:[UIColor darkGrayColor]];
    
    NSString *type = [self.arrayTypes objectAtIndex:section];
    
    NSString *count = @"";
    NSMutableArray *arrayGroupAlerts = [self.groupedAlerts objectForKey:type];
    if (arrayGroupAlerts.count == 0)
        count = @"None";
    else if (arrayGroupAlerts.count == 1)
        count = @"1 alert";
    else
        count = [NSString stringWithFormat:@"%lu alerts", (unsigned long)arrayGroupAlerts.count];
   
    /* Section header is in 0th index... */
    [label setText:type];
    [view addSubview:label];
    
    [labelCount setText:count];
    [view addSubview:labelCount];
    
    [view setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]];
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *type = [self.arrayTypes objectAtIndex:section];
    NSMutableArray *arrayGroupAlerts = [self.groupedAlerts objectForKey:type];
    return arrayGroupAlerts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *arrayGroupAlerts = [self.groupedAlerts objectForKey:[self.arrayTypes objectAtIndex:indexPath.section]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alertcell" forIndexPath:indexPath];
    
    // Configure the cell...
    Alert *alert = [arrayGroupAlerts objectAtIndex:indexPath.row];
    UILabel *lblLevel = (UILabel *)[cell viewWithTag:100];
    UILabel *lblLocation = (UILabel *)[cell viewWithTag:101];
    UILabel *lblNote1 = (UILabel *)[cell viewWithTag:102];
    UILabel *lblNote2 = (UILabel *)[cell viewWithTag:103];
    
    lblLevel.text = alert.location_level;
    lblLocation.text = alert.location_name;
    lblNote1.text = alert.note1;
    lblNote2.text = alert.note2;
    
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
    }
    else if (buttonIndex == 1){
        // Report for Service
    }
}

@end
