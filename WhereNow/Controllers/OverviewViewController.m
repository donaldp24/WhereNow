//
//  OverviewViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 02/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "OverviewViewController.h"
#import "EquipmentTabBarController.h"
#import "UIManager.h"
#import "ServerManager.h"

@interface OverviewViewController () <UIActionSheetDelegate>
{
    UIBarButtonItem *_backButton;
    Equipment *_equipment;
    __weak IBOutlet UILabel *lblManufacturer;
    __weak IBOutlet UILabel *lblModel;
    __weak IBOutlet UILabel *lblSerialNo;
    __weak IBOutlet UILabel *lblBarcodeNo;
    __weak IBOutlet UILabel *lblCurrentLevel;
    __weak IBOutlet UILabel *lblCurrentLocation;
    __weak IBOutlet UILabel *lblHomeLevel;
    __weak IBOutlet UILabel *lblHomeLocation;
    __weak IBOutlet UIImageView *ivEquipment;
    __weak IBOutlet UIImageView *ivModel;
}

@end

@implementation OverviewViewController

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
    

    //[self.navigationController.tabBarItem setImage:[UIImage imageNamed:@"overviewicon"]];
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"overviewicon_selected"]];
    
    // back button
    _backButton = [UIManager defaultBackButton:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = _backButton;
    
    UIBarButtonItem *_menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuicon"] style:UIBarButtonItemStylePlain target:self action:@selector(onMenu:)];
    self.navigationItem.rightBarButtonItem = _menuButton;
    
    EquipmentTabBarController *tabbarController = (EquipmentTabBarController *)self.tabBarController;
    _equipment = tabbarController.equipment;
    if (_equipment != nil)
    {
        self.navigationItem.title = [NSString stringWithFormat:@"%@-%@", _equipment.manufacturer_name, _equipment.model_name_no];
        
        lblManufacturer.text = _equipment.manufacturer_name;
        lblModel.text = _equipment.model_name_no;
        lblSerialNo.text =_equipment.serial_no;
        lblBarcodeNo.text = _equipment.barcode_no;
        lblCurrentLevel.text = @"";
        lblCurrentLocation.text = _equipment.current_location;
        lblHomeLevel.text = @"";
        lblHomeLocation.text = _equipment.home_location;
    }
    
    // set image
    [[ServerManager sharedManager] setImageContent:ivEquipment urlString:_equipment.equipment_file_location];
    [[ServerManager sharedManager] setImageContent:ivModel urlString:_equipment.model_file_location];

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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
