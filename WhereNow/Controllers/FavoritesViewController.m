//
//  FavoritesViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 01/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "FavoritesViewController.h"

#import "AppContext.h"
#import "SwipeTableView.h"
#import "EquipmentTabBarController.h"
#import "UIManager.h"
#import "LocationTableViewCell.h"
#import "ModelManager.h"


@interface FavoritesViewController () <SwipeTableViewDelegate> {
    UITableViewCell *editingCell;
    NSIndexPath *editingIndexPath;
    NSMutableArray *_expandingLocationArray;
    BOOL _firstLoad;
    NSMutableArray *_equipmentArray;
}

@property (nonatomic, weak) IBOutlet UISegmentedControl *segment;
@property (nonatomic, weak) IBOutlet SwipeTableView *tableView;

@property (nonatomic, strong) NSMutableArray *favoritesGenericArray;
@property (nonatomic, strong) NSMutableArray *favoritesEquipmentArray;

@property (nonatomic, strong) Generic *selectedGeneric;

@end

@implementation FavoritesViewController

- (void)loadData
{
    ModelManager *manager = [ModelManager sharedManager];
    
    // generic array -----------
    self.favoritesGenericArray = [manager retrieveFavoritesGenerics];
    

    // equipment array -------------------
    self.favoritesEquipmentArray = [manager retrieveFavoritesEquipments];

   
    _equipmentArray = self.favoritesEquipmentArray;
    
   
    // expandingLocationArray
    _expandingLocationArray = [[NSMutableArray alloc] init];

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
    
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"favoriteicon_selected"]];
    
    // set empty view to footer view
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;
    
    self.tableView.swipeDelegate = self;
    [self.tableView initControls];
    
    _firstLoad = YES;
    
    editingCell = nil;
    editingIndexPath = nil;
    
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
    
    if (!_firstLoad)
    {
        editingCell = nil;
        editingIndexPath = nil;
        
        self.favoritesGenericArray = [[ModelManager sharedManager] retrieveFavoritesGenerics];
        self.favoritesEquipmentArray = [[ModelManager sharedManager] retrieveFavoritesEquipments];
        
        if (self.segment.selectedSegmentIndex == 0)
        {
            //
        }
        else
        {
            if (self.selectedGeneric)
                _equipmentArray = [[ModelManager sharedManager] equipmentsForGeneric:self.selectedGeneric withBeacon:YES];
            else
                _equipmentArray = self.favoritesEquipmentArray;
        }
        
        [_expandingLocationArray removeAllObjects];
        
        [self.tableView reloadData];
    }
    
    _firstLoad = NO;
    
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

#pragma mark - actions
- (IBAction)onSegmentIndexChanged:(id)sender
{
    self.selectedGeneric = nil;
    if (editingCell)
        [self.tableView setEditing:NO atIndexPath:editingIndexPath cell:editingCell];
    
    editingIndexPath = nil;
    editingCell = nil;
    
    _equipmentArray = self.favoritesEquipmentArray;
    
    [_expandingLocationArray removeAllObjects];
    
    [self.tableView reloadData];
}

#pragma mark - tableview data source

static GenericsTableViewCell *_prototypeGenericsTableViewCell = nil;
static EquipmentTableViewCell *_prototypeEquipmentTableViewCell = nil;
static LocationTableViewCell *_prototypeLocationTableViewCell = nil;

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

- (LocationTableViewCell *)prototypeLocationTableViewCell
{
    if (_prototypeLocationTableViewCell == nil)
        _prototypeLocationTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"locationcell"];
    return _prototypeLocationTableViewCell;
}

- (NSArray *)dataForTableView:(UITableView *)tableView
{
    if (self.segment.selectedSegmentIndex == 0)
        return self.favoritesGenericArray;
    else
        return _equipmentArray;
}

- (BOOL)isGenericCell:(NSIndexPath *)indexPath
{
    BOOL isGenerics = YES;
    if (editingCell != nil)
    {
        if (indexPath.row <= editingIndexPath.row || indexPath.row > editingIndexPath.row + _expandingLocationArray.count)
            isGenerics = YES;
        else
            isGenerics = NO;
    }
    else
        isGenerics = YES;
    return isGenerics;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [self dataForTableView:tableView].count;
    count += _expandingLocationArray.count;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrayData = [self dataForTableView:tableView];
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        if([self isGenericCell:indexPath])
        {
            GenericsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"genericscell"];
            
            if (indexPath.row <= editingIndexPath.row)
                [cell bind:[arrayData objectAtIndex:indexPath.row] type:GenericsCellTypeFavorites];
            else
                [cell bind:[arrayData objectAtIndex:(indexPath.row - _expandingLocationArray.count)] type:GenericsCellTypeFavorites];
            
            cell.delegate = self;
            
            if (editingIndexPath != nil && editingIndexPath.row == indexPath.row)
            {
                editingIndexPath = indexPath;
                editingCell = cell;
                [cell setEditor:YES animate:NO];
            }
            return cell;
        }
        else
        {
            LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationcell"];
            [cell bind:[_expandingLocationArray objectAtIndex:indexPath.row - editingIndexPath.row - 1]];
            return cell;
        }
    }
    else
    {
        EquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipmentcell"];
        [cell bind:[arrayData objectAtIndex:indexPath.row] generic:self.selectedGeneric type:EquipmentCellTypeFavorites];
        cell.delegate = self;
        
        if (editingIndexPath != nil && editingIndexPath.row == indexPath.row)
        {
            editingIndexPath = indexPath;
            editingCell = cell;
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
            if ([self isGenericCell:indexPath])
                return [self prototypeGenericsTableViewCell].bounds.size.height;
            else
                return [self prototypeLocationTableViewCell].bounds.size.height;
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
        if ([self isGenericCell:indexPath])
        {
            self.selectedGeneric = ((GenericsTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath]).generic;
            // set equipmentArray
            _equipmentArray = [[ModelManager sharedManager] equipmentsForGeneric:self.selectedGeneric withBeacon:YES];
            
            [UIView animateWithDuration:0.3 animations:^{
                
                [self.segment setSelectedSegmentIndex:1];

                //[self.segment sendActionsForControlEvents:UIControlEventValueChanged];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
            }];
        }
        else
        {
            // location cell
        }
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
- (BOOL)canCloseEditingOnTap:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    if (self.segment.selectedSegmentIndex == 0)
    {
        if ([self isGenericCell:indexPath])
            return YES;
        return NO;
    }
    else
        return YES;
}


- (void)setEditing:(BOOL)editing atIndexPath:(id)indexPath cell:(UITableViewCell *)cell
{
    [self setEditing:editing atIndexPath:indexPath cell:cell animate:YES];
}

- (NSIndexPath *)setEditing:(BOOL)editing atIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell recalcIndexPath:(NSIndexPath *)recalcIndexPath
{
    NSIndexPath *curIndexPath = (NSIndexPath *)indexPath;
    int curRow = curIndexPath.row;
    int calcingRow = recalcIndexPath.row;
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        if (![self isGenericCell:indexPath])
        {
            return recalcIndexPath;
        }
    }
   
    if (editing)
    {
        editingCell = cell;
        editingIndexPath = indexPath;
    }
    
    NSIndexPath *calcedIndexPath = nil;
    if (recalcIndexPath)
        calcedIndexPath = [NSIndexPath indexPathForItem:recalcIndexPath.row inSection:recalcIndexPath.section];
    
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        if (![self isGenericCell:indexPath])
        {
            //
        }
        else
        {
            
            GenericsTableViewCell *tableCell = (GenericsTableViewCell *)cell;
            [tableCell setEditor:editing];
            
            
            if (editing)
            {
                // get location arrays
                [_expandingLocationArray removeAllObjects];
                
                _expandingLocationArray = [[ModelManager sharedManager] locationsForGeneric:tableCell.generic];
                
                
                // expand cell
                if (_expandingLocationArray.count > 0)
                {
                    [self.tableView beginUpdates];
                    NSMutableArray *newRows = [[NSMutableArray alloc] init];
                    for (int i = 0; i < _expandingLocationArray.count; i++) {
                        [newRows addObject:[NSIndexPath indexPathForRow:editingIndexPath.row + i + 1 inSection:0]];
                    }
                    [self.tableView insertRowsAtIndexPaths:newRows withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                }
            }
            else
            {
                // collapse cell
                
                if (_expandingLocationArray.count > 0)
                {
                    NSMutableArray *deleteRows = [[NSMutableArray alloc] init];
                    for (int i = 0; i < _expandingLocationArray.count; i++) {
                        [deleteRows addObject:[NSIndexPath indexPathForRow:editingIndexPath.row + i + 1 inSection:0]];
                    }
                    
                    if (recalcIndexPath != nil && recalcIndexPath.section == editingIndexPath.section)
                    {
                        int row1 = recalcIndexPath.row;
                        int row2 = editingIndexPath.row;
                        if (recalcIndexPath.row >= editingIndexPath.row + _expandingLocationArray.count + 1)
                        {
                            calcedIndexPath = [NSIndexPath indexPathForItem:recalcIndexPath.row - _expandingLocationArray.count inSection:recalcIndexPath.section];
                        }
                    }
                    
                    [_expandingLocationArray removeAllObjects];
                    
                    
                    [self.tableView beginUpdates];
                    
                    [self.tableView deleteRowsAtIndexPaths:deleteRows withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                }
            }
        }
    }
    else
    {
        EquipmentTableViewCell *tableCell = (EquipmentTableViewCell *)cell;
        [tableCell setEditor:editing];
    }
    
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
    if (tableView == self.tableView)
    {
        if (![self isGenericCell:indexPath])
            return NO;
        return YES;
    }
    return NO;
}

#pragma mark - GenericTableViewCellDelegate
- (void)onGenericDelete:(Generic *)generic
{
    if (editingCell)
        [self.tableView setEditing:NO atIndexPath:editingIndexPath cell:editingCell];
    
    editingIndexPath = nil;
    editingCell = nil;
    
    [_expandingLocationArray removeAllObjects];
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        [self.favoritesGenericArray removeObject:generic];
    }
    else
    {
        //[_equipmentArray removeObject:generic];
    }
    
    [self.tableView reloadData];
}

- (void)onGenericLocate:(Generic *)generic
{
    //
}

- (void)onEquipmentDelete:(Equipment *)equipment
{
    if (editingCell)
        [self.tableView setEditing:NO atIndexPath:editingIndexPath cell:editingCell];
    
    editingIndexPath = nil;
    editingCell = nil;
    
    [_expandingLocationArray removeAllObjects];
    
    if (self.segment.selectedSegmentIndex == 0)
    {
        //[self.favoritesGenericArray removeObject:generic];
    }
    else
    {
        [_equipmentArray removeObject:equipment];
    }
    
    [self.tableView reloadData];
}

- (void)onEquipmentLocate:(Equipment *)equipment
{
    //
}


@end
