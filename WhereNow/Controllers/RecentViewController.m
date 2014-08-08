//
//  RecentViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 02/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "RecentViewController.h"
#import "SwipeTableView.h"
#import "GenericsTableViewCell.h"
#import "EquipmentTableViewCell.h"
#import "AppContext.h"
#import "EquipmentTabBarController.h"
#import "UIManager.h"
#import "ModelManager.h"

@interface RecentViewController () <SwipeTableViewDelegate> {
    NSManagedObjectContext *_managedObjectContext;
    UITableViewCell *editingCell;
    NSIndexPath *editingIndexPath;
    BOOL _firstLoad;
    NSMutableArray *_equipmentArray;
}

@property (nonatomic, weak) IBOutlet UISegmentedControl *segment;
@property (nonatomic, weak) IBOutlet SwipeTableView *tableView;

@property (nonatomic, strong) NSMutableArray *recentGenericsArray;
@property (nonatomic, strong) NSMutableArray *recentEquipmentArray;
@property (nonatomic, strong) Generic *selectedGenerics;

@end

@implementation RecentViewController

- (void)loadData
{
    self.recentGenericsArray = [[ModelManager sharedManager] retrieveGenerics];
    self.recentEquipmentArray = [[ModelManager sharedManager] retrieveEquipments];
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
    
    // set empty view to footer view
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;
    
    self.tableView.swipeDelegate = self;
    [self.tableView initControls];
    
    _firstLoad = YES;
    
    editingCell = nil;
    editingIndexPath = nil;
    
    [self loadData];
    
    _equipmentArray = self.recentEquipmentArray;
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
    
    _equipmentArray = self.recentEquipmentArray;
    
    [self.tableView reloadData];
}

#pragma mark - tableview data source

static GenericsTableViewCell *_prototypeGenericsTableViewCell = nil;
static EquipmentTableViewCell *_prototypeEquipmentTableViewCell = nil;

- (GenericsTableViewCell *)prototypeGenericsTableViewCell
{
    if (_prototypeGenericsTableViewCell == nil)
        _prototypeGenericsTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"genericscell"];
    return _prototypeGenericsTableViewCell;
}

- (EquipmentTableViewCell *)prototypeEquipmentTableViewCell
{
    if (_prototypeEquipmentTableViewCell == nil)
        _prototypeEquipmentTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"equipmentcell"];
    return _prototypeEquipmentTableViewCell;
}

- (NSMutableArray *)dataForTableView:(UITableView *)tableView
{
    if (self.segment.selectedSegmentIndex == 0)
        return self.recentGenericsArray;
    else
        return _equipmentArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arrayData = [self dataForTableView:tableView];
    return arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrayData = [self dataForTableView:tableView];
    if (self.segment.selectedSegmentIndex == 0)
    {
        GenericsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"genericscell"];
        [cell bind:[arrayData objectAtIndex:indexPath.row] type:GenericsCellTypeFavorites];
        return cell;
    }
    else
    {
        EquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipmentcell"];
        [cell bind:[arrayData objectAtIndex:indexPath.row] generic:self.selectedGenerics type:EquipmentCellTypeFavorites];
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        if (self.segment.selectedSegmentIndex == 0)
        {
            return [self prototypeGenericsTableViewCell].bounds.size.height;
        }
        else
        {
            return [self prototypeEquipmentTableViewCell].bounds.size.height;
        }
    }
    return 30.0;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrayData = [self dataForTableView:tableView];
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            [self.segment setSelectedSegmentIndex:1];
            
            self.selectedGenerics = [self.recentGenericsArray objectAtIndex:indexPath.row];
            _equipmentArray = [[ModelManager sharedManager] equipmentsForGeneric:self.selectedGenerics];
            
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
        }];
    }
    else
    {
        Equipment *equipment = nil;
        equipment = [arrayData objectAtIndex:indexPath.row];
    
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
        GenericsTableViewCell *tableCell = (GenericsTableViewCell *)cell;
        [tableCell setEditor:editing];
    }
    else
    {
        EquipmentTableViewCell *tableCell = (EquipmentTableViewCell *)cell;
        [tableCell setEditor:editing];
    }
    
    if (editing)
    {
        editingCell = cell;
        editingIndexPath = indexPath;
    }
    else
    {
        editingCell = nil;
        editingIndexPath = nil;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
        return YES;
    return NO;
}

@end
