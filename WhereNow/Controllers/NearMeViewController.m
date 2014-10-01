//
//  NearMeViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 31/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "NearMeViewController.h"
#import "SwipeTableView.h"
#import "AppContext.h"
#import "UIManager.h"
#import "EquipmentTabBarController.h"
#import "ModelManager.h"
#import "BackgroundTaskManager.h"
#import "ServerManager.h"
#import "UserContext.h"
#import "CommonGenericTableViewCell.h"
#import "CommonEquipmentTableViewCell.h"

@interface NearMeViewController () <SwipeTableViewDelegate> {
    NSManagedObjectContext *_managedObjectContext;
    int editingSection;
    UITableViewCell *editingCell;
    NSIndexPath *editingIndexPath;
    BOOL _firstLoad;
    NSMutableArray *_vicinityEquipments;
    NSMutableArray *_locationEquipments;
}

@property (nonatomic, weak) IBOutlet UISegmentedControl *segment;
@property (nonatomic, weak) IBOutlet SwipeTableView *tableView;

@property (nonatomic, strong) NSMutableArray *nearmeGenericsArray;
@property (nonatomic, strong) NSMutableArray *nearmeVicinityEquipments;
@property (nonatomic, strong) NSMutableArray *nearmeLocationEquipments;
@property (nonatomic, strong) Generic *selectedGenerics;

@property (nonatomic, weak) UIRefreshControl *refresh;

@end

@implementation NearMeViewController

- (void)loadDataWithGeneric:(Generic *)selectedGeneric
{
    BackgroundTaskManager *taskManager = [BackgroundTaskManager sharedManager];
    if (selectedGeneric == nil)
    {
        self.nearmeGenericsArray = [[NSMutableArray alloc] initWithArray:taskManager.arrayNearmeGenerics];
        self.nearmeVicinityEquipments = [[NSMutableArray alloc] initWithArray:taskManager.arrayVicinityEquipments];
        self.nearmeLocationEquipments = [[NSMutableArray alloc] initWithArray:taskManager.arrayLocationEquipments];
    }
    else
    {
        self.nearmeGenericsArray = [[NSMutableArray alloc] initWithArray:taskManager.arrayNearmeGenerics];
        self.nearmeVicinityEquipments = [[NSMutableArray alloc] init];
        self.nearmeLocationEquipments = [[NSMutableArray alloc] init];
        
        for (Equipment *equipment in taskManager.arrayVicinityEquipments) {
            if ([equipment.generic_id isEqual:selectedGeneric.generic_id])
                [self.nearmeVicinityEquipments addObject:equipment];
        }
        
        for (Equipment *equipment in taskManager.arrayLocationEquipments) {
            if ([equipment.generic_id isEqual:selectedGeneric.generic_id])
                [self.nearmeLocationEquipments addObject:equipment];
        }
    }
    
    _vicinityEquipments = self.nearmeVicinityEquipments;
    _locationEquipments = self.nearmeLocationEquipments;
}

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
    
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"nearmeicon_selected"]];
    
    // set empty view to footer view
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;
    
    self.tableView.swipeDelegate = self;
    [self.tableView initControls];
    
    _firstLoad = YES;
    
    editingSection = -1;
    editingCell = nil;
    editingIndexPath = nil;
    
    self.selectedGenerics = nil;
    [self loadDataWithGeneric:self.selectedGenerics];
    
    _vicinityEquipments = self.nearmeVicinityEquipments;
    _locationEquipments = self.nearmeLocationEquipments;
    
    UIRefreshControl *refresh = [UIRefreshControl new];
    //refresh.tintColor = [UIColor whiteColor];
    [refresh addTarget:self action:@selector(refreshPulled) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
    self.refresh = refresh;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonGenericTableViewCell" bundle:nil] forCellReuseIdentifier:kDefaultCommonGenericTableViewCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonEquipmentTableViewCell" bundle:nil] forCellReuseIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChanged:) name:kBackgroundUpdateLocationInfoNotification object:nil];
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
    
    //self.navigationController.navigationBar.barStyle = [UIManager navbarStyle];
    //self.navigationController.navigationBar.tintColor = [UIManager navbarTintColor];
    self.navigationController.navigationBar.titleTextAttributes = [UIManager navbarTitleTextAttributes];
    //self.navigationController.navigationBar.barTintColor = [UIManager navbarBarTintColor];
    
    if (!_firstLoad)
    {
        editingSection = -1;
        editingCell = nil;
        editingIndexPath = nil;
        
        //[_expandingLocationArray removeAllObjects];
        
        [self.tableView reloadData];
    }
    
    _firstLoad = NO;
    
}

#pragma mark - actions
- (IBAction)onSegmentIndexChanged:(id)sender
{
    self.selectedGenerics = nil;
    if (editingCell)
        [self.tableView setEditing:NO atIndexPath:editingIndexPath cell:editingCell];
    
    editingSection = -1;
    editingIndexPath = nil;
    editingCell = nil;
    
    [self.tableView reloadData];
}

#pragma mark - tableview data source

static CommonGenericTableViewCell *_prototypeGenericsTableViewCell = nil;
static CommonEquipmentTableViewCell *_prototypeEquipmentTableViewCell = nil;

- (CommonGenericTableViewCell *)prototypeGenericsTableViewCell
{
    if (_prototypeGenericsTableViewCell == nil)
    {
        _prototypeGenericsTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kDefaultCommonGenericTableViewCellIdentifier];
        if (_prototypeGenericsTableViewCell == nil)
        {
            _prototypeGenericsTableViewCell = [[CommonGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonGenericTableViewCellIdentifier];
        }
    }
    return _prototypeGenericsTableViewCell;
}

- (CommonEquipmentTableViewCell *)prototypeEquipmentTableViewCell
{
    if (_prototypeEquipmentTableViewCell == nil)
    {
        _prototypeEquipmentTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
        if (_prototypeEquipmentTableViewCell == nil)
        {
            _prototypeEquipmentTableViewCell = [[CommonEquipmentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
        }
    }
    return _prototypeEquipmentTableViewCell;
}

- (NSMutableArray *)dataForTableView:(UITableView *)tableView withSection:(int)section
{
    if (self.segment.selectedSegmentIndex == 0)
        return self.nearmeGenericsArray;
    else
    {
        if (section == 0)
            return _vicinityEquipments;
        else
            return _locationEquipments;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.segment.selectedSegmentIndex == 0)
        return 0;
    else
    {
        if (section == 0)
            return 27;
        else
            return 27;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 3, tableView.frame.size.width, 22)];
    [label setFont:[UIFont boldSystemFontOfSize:17]];
    NSString *string = @"IMMEDIATE VICINITY";
    if (section > 0)
        string = @"CURRENT LOCATION";

    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]];
    return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segment.selectedSegmentIndex == 0 && section == 1)
        return 0;
    NSArray *arrayData = [self dataForTableView:tableView withSection:(int)section];
    return arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrayData = [self dataForTableView:tableView withSection:(int)indexPath.section];
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        CommonGenericTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCommonGenericTableViewCellIdentifier];
        if (cell == nil)
        {
            cell = [[CommonGenericTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonGenericTableViewCellIdentifier];
        }
        [cell bind:[arrayData objectAtIndex:indexPath.row] type:CommonGenericsCellTypeNearme];
        
        if (editingIndexPath != nil && editingIndexPath.row == indexPath.row && editingSection == indexPath.section)
        {
            editingIndexPath = indexPath;
            editingCell = cell;
            editingSection = (int)indexPath.section;
            [cell setEditor:YES animate:NO];
        }
        return cell;
    }
    else
    {
        CommonEquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
        if (cell == nil)
        {
            cell = [[CommonEquipmentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCommonEquipmentTableViewCellIdentifier];
        }
        [cell bind:[arrayData objectAtIndex:indexPath.row] generic:self.selectedGenerics type:CommonEquipmentCellTypeNearme];
        
        if (editingIndexPath != nil && editingIndexPath.row == indexPath.row && editingSection == indexPath.section)
        {
            editingIndexPath = indexPath;
            editingCell = cell;
            editingSection = (int)indexPath.section;
            [cell setEditor:YES animate:NO];
        }
         return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        if (self.segment.selectedSegmentIndex == 0)
        {
            return [[self prototypeGenericsTableViewCell] heightForCell];
        }
        else
        {
            return [[self prototypeEquipmentTableViewCell] heightForCell];
        }
    }
    return 30.0;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrayData = [self dataForTableView:tableView withSection:(int)indexPath.section];
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        [UIView animateWithDuration:0.3 animations:^{
            [self.segment setSelectedSegmentIndex:1];
            self.selectedGenerics = [self.nearmeGenericsArray objectAtIndex:indexPath.row];
            
            [self loadDataWithGeneric:self.selectedGenerics];
            
            
            //[self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSRangeFromString(@"0-1")] withRowAnimation:UITableViewRowAnimationLeft];
            [UIView animateWithDuration:1.0 animations:^() {
                [self.tableView reloadData];
            }];
            
            // save selected generic to recent list
            [[ModelManager sharedManager] addRecentGeneric:self.selectedGenerics];
        }];
    }
    else
    {
        Equipment *equipment = nil;
        equipment = [arrayData objectAtIndex:indexPath.row];

        // save selected equipment to recent list
        [[ModelManager sharedManager] addRecentEquipment:equipment];

        // push new tab bar
        EquipmentTabBarController *equipTabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"EquipmentTabBarController"];
        equipTabBar.equipment = equipment;
        
        // set animation style
        equipTabBar.modalTransitionStyle = [UIManager detailModalTransitionStyle];
        [self presentViewController:equipTabBar animated:YES completion:nil];
    }
    
}

#pragma mark - swipe table view delegate
- (void)setEditing:(BOOL)editing atIndexPath:(id)indexPath cell:(UITableViewCell *)cell
{
    [self setEditing:editing atIndexPath:indexPath cell:cell animate:YES];
}

- (void)setEditing:(BOOL)editing atIndexPath:indexPath cell:(UITableViewCell *)cell animate:(BOOL)animate
{
    if (self.segment.selectedSegmentIndex == 0)
    {
        CommonGenericTableViewCell *tableCell = (CommonGenericTableViewCell *)cell;
        [tableCell setEditor:editing];
    }
    else
    {
        CommonEquipmentTableViewCell *tableCell = (CommonEquipmentTableViewCell *)cell;
        [tableCell setEditor:editing];
    }
    
    if (editing)
    {
        editingCell = cell;
        editingIndexPath = indexPath;
        editingSection = (int)((NSIndexPath*)indexPath).section;
    }
    else
    {
        editingSection = -1;
        editingCell = nil;
        editingIndexPath = nil;
    }
}

- (NSIndexPath *)setEditing:(BOOL)editing atIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell recalcIndexPath:(NSIndexPath *)recalcIndexPath
{
    //NSIndexPath *curIndexPath = (NSIndexPath *)indexPath;
    //int curRow = curIndexPath.row;
    //int calcingRow = recalcIndexPath.row;

    if (editing)
    {
        editingSection = (int)indexPath.section;
        editingCell = cell;
        editingIndexPath = indexPath;
    }
    
    NSIndexPath *calcedIndexPath = nil;
    if (recalcIndexPath)
        calcedIndexPath = [NSIndexPath indexPathForItem:recalcIndexPath.row inSection:recalcIndexPath.section];
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        CommonGenericTableViewCell *tableCell = (CommonGenericTableViewCell *)cell;
        [tableCell setEditor:editing];
    }
    else
    {
        CommonEquipmentTableViewCell *tableCell = (CommonEquipmentTableViewCell *)cell;
        [tableCell setEditor:editing];
    }
    
    if (!editing)
    {
        editingSection = -1;
        editingCell = nil;
        editingIndexPath = nil;
    }
    
    return calcedIndexPath;
}

- (BOOL)canCloseEditingOnTap:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
        return YES;
    return NO;
}

#pragma mark - Refresh pulled
- (void) refreshPulled
{
    NSLog(@"refreshPulled");
    [self.refresh beginRefreshing];
    
    // rerequest with nearme request
    NSMutableArray *arrayBeacons = [[BackgroundTaskManager sharedManager] nearmeBeacons];
#ifdef DEBUG
    if (arrayBeacons.count == 0)
    {
        //CLBeacon *beacon = [[CLBeacon alloc] init];
        //beacon.proximityUUID = [[NSUUID alloc] initWithUUIDString:@""];
    }
#endif
    [[BackgroundTaskManager sharedManager] requestLocationInfo:arrayBeacons complete:^() {
        
        // reload data
        [[NSOperationQueue mainQueue] addOperationWithBlock:^() {
            
            [self loadDataWithGeneric:self.selectedGenerics];
            
            // call end refreshing when get response
            [self.refresh endRefreshing];
            
            [self.tableView reloadData];
        }];
        
    }];
}

- (void) onChanged:(id)sender
{
    if (_firstLoad)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self loadDataWithGeneric:self.selectedGenerics];
        [self.tableView reloadData];
    });
}


@end
