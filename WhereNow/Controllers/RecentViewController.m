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
#import "RecentLocationTableViewCell.h"
#import "RecentEquipmentsViewController.h"

@interface RecentViewController () <SwipeTableViewDelegate> {
    NSManagedObjectContext *_managedObjectContext;
    UITableViewCell *editingCell;
    NSIndexPath *editingIndexPath;
    NSMutableArray *_expandingLocationArray;
    BOOL _firstLoad;
    NSMutableArray *_equipmentArray;
}

@property (nonatomic, weak) IBOutlet SwipeTableView *tableView;

@property (nonatomic, strong) NSMutableArray *recentGenericsArray;
@property (nonatomic, strong) NSMutableArray *recentEquipmentArray;
@property (nonatomic, strong) NSMutableArray *arrayData;

@end

@implementation RecentViewController

- (void)loadData
{
    self.recentGenericsArray = [[ModelManager sharedManager] retrieveRecentGenerics];
    self.recentEquipmentArray = [[ModelManager sharedManager] retrieveRecentEquipments];
    
    if (self.recentGenericsArray == nil || self.recentGenericsArray.count == 0)
    {
        if (self.recentEquipmentArray == nil || self.recentEquipmentArray.count == 0)
            self.arrayData = [[NSMutableArray alloc] init];
        else
            self.arrayData = [self.recentEquipmentArray mutableCopy];
    }
    else
    {
        if (self.recentEquipmentArray == nil || self.recentEquipmentArray.count == 0)
            self.arrayData = [self.recentGenericsArray mutableCopy];
        else
        {
            self.arrayData = [[NSMutableArray alloc] init];
            int i = 0;
            int j = 0;
            while (i < self.recentGenericsArray.count && j < self.recentEquipmentArray.count) {
                Generic *generic = [self.recentGenericsArray objectAtIndex:i];
                Equipment *equipment = [self.recentEquipmentArray objectAtIndex:j];
                if ([generic.recenttime compare:equipment.recenttime] == NSOrderedDescending)
                {
                    [self.arrayData addObject:generic];
                    i++;
                }
                else
                {
                    [self.arrayData addObject:equipment];
                    j++;
                }
            }
            
            if (i == self.recentGenericsArray.count)
            {
                if (j == self.recentEquipmentArray.count)
                {
                    //
                }
                else
                {
                    for (int k = j; k < self.recentEquipmentArray.count; k++) {
                        [self.arrayData addObject:[self.recentEquipmentArray objectAtIndex:k]];
                    }
                }
            }
            else
            {
                for (int k = i; k < self.recentGenericsArray.count; k++) {
                    [self.arrayData addObject:[self.recentGenericsArray objectAtIndex:k]];
                }
            }
        }
    }
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
    
    // expandingLocationArray
    _expandingLocationArray = [[NSMutableArray alloc] init];
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
        
        [_expandingLocationArray removeAllObjects];
        
        [self loadData];
        
        [self.tableView reloadData];
    }
    
    _firstLoad = NO;
    
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
    int count = self.arrayData.count;
    count += _expandingLocationArray.count;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if([self isGenericCell:indexPath])
    {
        NSManagedObject *obj = nil;
        if (editingIndexPath == nil || indexPath.row <= editingIndexPath.row)
            obj = [self.arrayData objectAtIndex:indexPath.row];
        else
            obj = [self.arrayData objectAtIndex:(indexPath.row - _expandingLocationArray.count)];
        
        NSString *entityName = [obj entity].name;
        if ([entityName isEqualToString:@"Generic"])
        {
            GenericsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"genericscell"];
            
            [cell bind:(Generic *)obj type:GenericsCellTypeSearch];
            
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
            EquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipmentcell"];
            [cell bind:(Equipment *)obj generic:nil type:EquipmentCellTypeSearch];
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
    else
    {
        LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationcell"];
        [cell bind:[_expandingLocationArray objectAtIndex:indexPath.row - editingIndexPath.row - 1]];
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        if ([self isGenericCell:indexPath])
        {
            NSManagedObject *obj = nil;
            if (editingIndexPath == nil || indexPath.row <= editingIndexPath.row)
                obj = [self.arrayData objectAtIndex:indexPath.row];
            else
                obj = [self.arrayData objectAtIndex:(indexPath.row - _expandingLocationArray.count)];
            
            NSString *entityName = [obj entity].name;
            if ([entityName isEqualToString:@"Generic"])
                return [self prototypeGenericsTableViewCell].bounds.size.height;
            else
                return [self prototypeEquipmentTableViewCell].bounds.size.height;
        }
        else
            return [self prototypeLocationTableViewCell].bounds.size.height;
    }
    return 30.0;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if ([self isGenericCell:indexPath])
    {
        NSManagedObject *obj = nil;
        if (editingIndexPath == nil || indexPath.row <= editingIndexPath.row)
            obj = [self.arrayData objectAtIndex:indexPath.row];
        else
            obj = [self.arrayData objectAtIndex:(indexPath.row - _expandingLocationArray.count)];
        
        NSString *entityName = [obj entity].name;
        if ([entityName isEqualToString:@"Generic"])
        {
            RecentEquipmentsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RecentEquipmentsViewController"];
            vc.generic = (Generic *)obj;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            Equipment *equipment = nil;
            equipment = (Equipment *)obj;
            
            // push new tab bar
            EquipmentTabBarController *equipTabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"EquipmentTabBarController"];
            equipTabBar.equipment = equipment;
            
            // set animation style
            equipTabBar.modalTransitionStyle = [UIManager detailModalTransitionStyle];
            [self presentViewController:equipTabBar animated:YES completion:nil];
        }
    }
    else
    {
        // location cell
    }
}

#pragma mark - swipe table view delegate
- (BOOL)canCloseEditingOnTap:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    if ([self isGenericCell:indexPath])
        return YES;
    return NO;
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
    

    if (![self isGenericCell:indexPath])
    {
        return recalcIndexPath;
    }

    
    if (editing)
    {
        editingCell = cell;
        editingIndexPath = indexPath;
    }
    
    NSIndexPath *calcedIndexPath = nil;
    if (recalcIndexPath)
        calcedIndexPath = [NSIndexPath indexPathForItem:recalcIndexPath.row inSection:recalcIndexPath.section];
    
    

    if (![self isGenericCell:indexPath])
    {
        //
    }
    else
    {
        NSManagedObject *obj = nil;
        if (editingIndexPath == nil || indexPath.row <= editingIndexPath.row)
            obj = [self.arrayData objectAtIndex:indexPath.row];
        else
            obj = [self.arrayData objectAtIndex:(indexPath.row - _expandingLocationArray.count)];
        
        NSString *entityName = [obj entity].name;
        if ([entityName isEqualToString:@"Generic"])
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
        else
        {
            EquipmentTableViewCell *tableCell = (EquipmentTableViewCell *)cell;
            [tableCell setEditor:editing];
        }
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
}

- (void)onGenericLocate:(Generic *)generic
{
}

- (void)onGenericFavorite:(Generic *)generic
{
}

- (void)onEquipmentDelete:(Equipment *)equipment
{
}

- (void)onEquipmentLocate:(Equipment *)equipment
{
}

- (void)onEquipmentFavorite:(Equipment *)equipment
{
}

@end
