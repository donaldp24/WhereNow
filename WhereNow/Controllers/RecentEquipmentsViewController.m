//
//  RecentEquipmentsViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 19/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "RecentEquipmentsViewController.h"
#import "RecentEquipmentDetailTableViewCell.h"
#import "ModelManager.h"
#import "EquipmentTabBarController.h"
#import "UIManager.h"

@interface RecentEquipmentsViewController () {
    UITableViewCell *editingCell;
    NSIndexPath *editingIndexPath;
    
    UIBarButtonItem *_backButton;
}

@property (nonatomic, strong) IBOutlet SwipeTableView *tableView;

@property (nonatomic, strong) NSMutableArray *arrayEquipments;

@end

@implementation RecentEquipmentsViewController

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
    
    editingCell = nil;
    editingIndexPath = nil;
    
    if (self.generic)
        self.arrayEquipments = [[ModelManager sharedManager] equipmentsForGeneric:self.generic withBeacon:YES];
    else
        self.arrayEquipments = [[NSMutableArray alloc] init];
    
    // back button
    _backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backicon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = _backButton;
    
    // set empty view to footer view
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;
    
    self.tableView.swipeDelegate = self;
    [self.tableView initControls];
    
    // set title of navigation item
    if (self.generic)
    {
        self.navigationItem.title = self.generic.generic_name;
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

#pragma mark Table View Data Source
static EquipmentTableViewCell *_prototypeEquipmentTableViewCell = nil;
- (EquipmentTableViewCell *)prototypeEquipmentTableViewCell
{
    if (_prototypeEquipmentTableViewCell == nil)
        _prototypeEquipmentTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"equipmentcell"];
    return _prototypeEquipmentTableViewCell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayEquipments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipmentcell"];
    [cell bind:[self.arrayEquipments objectAtIndex:indexPath.row] generic:self.generic type:EquipmentCellTypeSearch];
    return cell;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Equipment *equipment = nil;
    equipment = [self.arrayEquipments objectAtIndex:indexPath.row];
    
    // push new tab bar
    EquipmentTabBarController *equipTabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"EquipmentTabBarController"];
    equipTabBar.equipment = equipment;
    
    // set animation style
    equipTabBar.modalTransitionStyle = [UIManager detailModalTransitionStyle];
    [self presentViewController:equipTabBar animated:YES completion:nil];
    
}

#pragma mark - swipe table view delegate
- (BOOL)canCloseEditingOnTap:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)setEditing:(BOOL)editing atIndexPath:(id)indexPath cell:(UITableViewCell *)cell
{
    [self setEditing:editing atIndexPath:indexPath cell:cell animate:YES];
}

- (NSIndexPath *)setEditing:(BOOL)editing atIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell recalcIndexPath:(NSIndexPath *)recalcIndexPath
{
    if (editing)
    {
        editingCell = cell;
        editingIndexPath = indexPath;
    }
    
    NSIndexPath *calcedIndexPath = nil;
    if (recalcIndexPath)
        calcedIndexPath = [NSIndexPath indexPathForItem:recalcIndexPath.row inSection:recalcIndexPath.section];
    
    
    EquipmentTableViewCell *tableCell = (EquipmentTableViewCell *)cell;
    [tableCell setEditor:editing];

    
    if (!editing)
    {
        editingCell = nil;
        editingIndexPath = nil;
    }
    
    return calcedIndexPath;
}

- (void)setEditing:(BOOL)editing atIndexPath:indexPath cell:(UITableViewCell *)cell animate:(BOOL)animate
{
    [self setEditing:editing atIndexPath:indexPath cell:cell recalcIndexPath:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark - Back button
- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
