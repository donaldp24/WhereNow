//
//  FavoritesViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 01/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "FavoritesViewController.h"
#import "GenericsTableViewCell.h"
#import "EquipmentTableViewCell.h"
#import "AppContext.h"
#import "SwipeTableView.h"
#import "EquipmentTabBarController.h"
#import "UIManager.h"
#import "LocationTableViewCell.h"


@interface FavoritesViewController () <SwipeTableViewDelegate> {
    NSManagedObjectContext *_managedObjectContext;
    UITableViewCell *editingCell;
    NSIndexPath *editingIndexPath;
    NSMutableArray *_expandingLocationArray;
    BOOL _firstLoad;
}

@property (nonatomic, weak) IBOutlet UISegmentedControl *segment;
@property (nonatomic, weak) IBOutlet SwipeTableView *tableView;

@property (nonatomic, strong) NSMutableArray *favoritesGenericsArray;
@property (nonatomic, strong) NSMutableArray *favoritesEquipmentArray;
@property (nonatomic, strong) Generics *selectedGenerics;

@property (nonatomic, strong) NSMutableArray *favoritesLocationArray;

@end

@implementation FavoritesViewController

- (void)loadData
{
    _managedObjectContext = [AppContext sharedAppContext].managedObjectContext;
    
    self.favoritesGenericsArray = [[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Generics"
                                   inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSSortDescriptor *descriptor1 = [[NSSortDescriptor alloc] initWithKey:@"uid" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:descriptor1, nil];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects.count > 0)
    {
        for (int i = 0; i < [fetchedObjects count]; i++) {
            Generics *generics = (Generics *)[fetchedObjects objectAtIndex:i];
            NSFetchRequest *fetchEquipmentRequest = [[NSFetchRequest alloc] init];
            
            entity = [NSEntityDescription
                      entityForName:@"Equipment"
                      inManagedObjectContext:_managedObjectContext];
            [fetchEquipmentRequest setEntity:entity];
            
            NSPredicate* pred = [NSPredicate predicateWithFormat:
                                 @"generics == %@", generics];
            
            [fetchEquipmentRequest setPredicate:pred];
            
            NSArray *fetchedEquipments = [_managedObjectContext executeFetchRequest:fetchEquipmentRequest error:&error];
            for (int j = 0; j < [fetchedEquipments count]; j++) {
                Equipment *equipment = (Equipment *)[fetchedEquipments objectAtIndex:j];
                equipment.generics = generics;
            }
            
            [self.favoritesGenericsArray addObject:generics];
        }
    }
    else
    {
        
        // locations
        Location *location1 = nil;
        location1 = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Location"
                     inManagedObjectContext:_managedObjectContext];
        location1.name = @"location1";
        
        Location *location2 = nil;
        location2 = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Location"
                     inManagedObjectContext:_managedObjectContext];
        location2.name = @"location2";
        
        Location *location3 = nil;
        location3 = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Location"
                     inManagedObjectContext:_managedObjectContext];
        location3.name = @"location3";
        
        
        Generics *generics = nil;
        Equipment *equipment = nil;
        
        // create generics
        generics = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Generics"
                    inManagedObjectContext:_managedObjectContext];
        
        generics.uid = [NSNumber numberWithInt:1];
        generics.name = @"Wheelchair";
        generics.numberOfNearby = [NSNumber numberWithInt:3];
        generics.notes = @"1 stationary for two 1 stationary for two";
        
        equipment = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Equipment"
                     inManagedObjectContext:_managedObjectContext];
        equipment.name = @"INVACARE - ACTION3NG";
        equipment.currentLocation = @"Level 3 Storeroom";
        equipment.serialNumber = @"ASED0-1123";
        equipment.generics = generics;
        equipment.location = location2;
        
        equipment = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Equipment"
                     inManagedObjectContext:_managedObjectContext];
        equipment.name = @"INVACARE - ACTION3NG";
        equipment.currentLocation = @"Level 3 Storeroom";
        equipment.serialNumber = @"ASED0-1123";
        equipment.generics = generics;
        equipment.location = location1;
        
        equipment = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Equipment"
                     inManagedObjectContext:_managedObjectContext];
        equipment.name = @"INVACARE - ACTION3NG";
        equipment.currentLocation = @"Level 3 Storeroom";
        equipment.serialNumber = @"ASED0-1123";
        equipment.generics = generics;
        
        self.selectedGenerics = generics;
        
        [self.favoritesGenericsArray addObject:generics];
        
        // create generics
        generics = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Generics"
                    inManagedObjectContext:_managedObjectContext];
        
        generics.uid = [NSNumber numberWithInt:2];
        generics.name = @"Bladder Volume Monitor";
        generics.numberOfNearby = [NSNumber numberWithInt:1];
        generics.notes = @"One in ICU to be returned to Theatres";
        
        equipment = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Equipment"
                     inManagedObjectContext:_managedObjectContext];
        equipment.name = @"INVACARE - ACTION3NG";
        equipment.currentLocation = @"Level 3 Storeroom";
        equipment.serialNumber = @"ASED0-1123";
        equipment.generics = generics;
        equipment.location = location3;
        
        equipment = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Equipment"
                     inManagedObjectContext:_managedObjectContext];
        equipment.name = @"INVACARE - ACTION3NG";
        equipment.currentLocation = @"Level 3 Storeroom";
        equipment.serialNumber = @"ASED0-1123";
        equipment.generics = generics;
        equipment.location = location2;
        
        equipment = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Equipment"
                     inManagedObjectContext:_managedObjectContext];
        equipment.name = @"INVACARE - ACTION3NG";
        equipment.currentLocation = @"Level 3 Storeroom";
        equipment.serialNumber = @"ASED0-1123";
        equipment.generics = generics;
        
        
        equipment = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Equipment"
                     inManagedObjectContext:_managedObjectContext];
        equipment.name = @"INVACARE - ACTION3NG";
        equipment.currentLocation = @"Level 3 Storeroom";
        equipment.serialNumber = @"ASED0-1123";
        equipment.generics = generics;
        
        [self.favoritesGenericsArray addObject:generics];
        
        
        // create generics
        generics = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Generics"
                    inManagedObjectContext:_managedObjectContext];
        
        generics.uid = [NSNumber numberWithInt:3];
        generics.name = @"Pump, Infusion Module";
        generics.numberOfNearby = [NSNumber numberWithInt:12];
        generics.notes = @"1 stationary for two .....";
        
        equipment = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Equipment"
                     inManagedObjectContext:_managedObjectContext];
        equipment.name = @"INVACARE - ACTION3NG";
        equipment.currentLocation = @"Level 3 Storeroom";
        equipment.serialNumber = @"ASED0-1123";
        equipment.generics = generics;
        
        equipment = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Equipment"
                     inManagedObjectContext:_managedObjectContext];
        equipment.name = @"INVACARE - ACTION3NG";
        equipment.currentLocation = @"Level 3 Storeroom";
        equipment.serialNumber = @"ASED0-1123";
        equipment.generics = generics;
        equipment.location = location1;
        
        equipment = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Equipment"
                     inManagedObjectContext:_managedObjectContext];
        equipment.name = @"INVACARE - ACTION3NG";
        equipment.currentLocation = @"Level 3 Storeroom";
        equipment.serialNumber = @"ASED0-1123";
        equipment.generics = generics;
        equipment.location = location3;
        
        equipment = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Equipment"
                     inManagedObjectContext:_managedObjectContext];
        equipment.name = @"INVACARE - ACTION3NG";
        equipment.currentLocation = @"Level 3 Storeroom";
        equipment.serialNumber = @"ASED0-1123";
        equipment.generics = generics;
        
        
        equipment = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Equipment"
                     inManagedObjectContext:_managedObjectContext];
        equipment.name = @"INVACARE - ACTION3NG";
        equipment.currentLocation = @"Level 3 Storeroom";
        equipment.serialNumber = @"ASED0-1123";
        equipment.generics = generics;
        
        
        [self.favoritesGenericsArray addObject:generics];
        
        [[AppContext sharedAppContext] saveContext];
    }
    
    self.favoritesEquipmentArray = [[NSMutableArray alloc] init];
    
    
    // get location array
    self.favoritesLocationArray = [[NSMutableArray alloc] init];
    entity = [NSEntityDescription
              entityForName:@"Location"
              inManagedObjectContext:_managedObjectContext];
    fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSArray *fetchedLocations = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedLocations.count > 0)
    {
        for (int i = 0; i < [fetchedLocations count]; i++) {
            Location *location = (Location *)[fetchedLocations objectAtIndex:i];
            [self.favoritesLocationArray addObject:location];
        }
    }
    
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
    self.selectedGenerics = nil;
    if (editingCell)
        [self.tableView setEditing:NO atIndexPath:editingIndexPath cell:editingCell];
    
    editingIndexPath = nil;
    editingCell = nil;
    
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
    if (self.segment.selectedSegmentIndex == 0)
        return self.favoritesGenericsArray.count + _expandingLocationArray.count;
    else
    {
        if (self.selectedGenerics != nil)
            return self.selectedGenerics.equipments.count;
        else
            return self.favoritesEquipmentArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segment.selectedSegmentIndex == 0)
    {
        if([self isGenericCell:indexPath])
        {
            GenericsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"genericscell"];
            [cell bind:[self.favoritesGenericsArray objectAtIndex:indexPath.row] type:GenericsCellTypeFavorites];
            //[cell setEditing:NO];
            [self.tableView setEditing:NO animated:NO];
            return cell;
        }
        else
        {
            LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationcell"];
            [cell bind:[_expandingLocationArray objectAtIndex:indexPath.row - editingIndexPath.row - 1]];
            //[cell setEditing:NO];
            [self.tableView setEditing:NO animated:NO];
            return cell;
        }
    }
    else
    {
        EquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipmentcell"];
        if (self.selectedGenerics != nil)
            [cell bind:[[self.selectedGenerics.equipments allObjects] objectAtIndex:indexPath.row] type:EquipmentCellTypeFavorites];
        else
            [cell bind:[self.favoritesEquipmentArray objectAtIndex:indexPath.row] type:EquipmentCellTypeFavorites];
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
    if (self.segment.selectedSegmentIndex == 0)
    {
        if ([self isGenericCell:indexPath])
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self.segment setSelectedSegmentIndex:1];
                self.selectedGenerics = [self.favoritesGenericsArray objectAtIndex:indexPath.row];
                //[self.segment sendActionsForControlEvents:UIControlEventValueChanged];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
            }];
        }
        else
        {
            //
        }
    }
    else
    {
        Equipment *equipment = nil;
        if (self.selectedGenerics)
        {
            equipment = [[self.selectedGenerics.equipments allObjects] objectAtIndex:indexPath.row];
        }
        else
        {
            equipment = [self.favoritesEquipmentArray objectAtIndex:indexPath.row];
        }
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
                for (Location *location in self.favoritesLocationArray) {
                    BOOL isEquipment = NO;
                    for (Equipment *equipment in location.equipments) {
                        if ([tableCell.generics.equipments containsObject:equipment])
                        {
                            isEquipment = YES;
                            break;
                        }
                    }
                    if (isEquipment)
                        [_expandingLocationArray addObject:location];
                }
                
                
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


@end
