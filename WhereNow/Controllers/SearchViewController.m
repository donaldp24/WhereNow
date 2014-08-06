//
//  SearchViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "SearchViewController.h"
#import "GenericsTableViewCell.h"
#import "EquipmentTableViewCell.h"
#import "AppContext.h"
#import "OverviewViewController.h"
#import "EquipmentTabBarController.h"
#import "UIManager.h"
#import "location.h"

#define GENERICS_INDEX      0
#define EQUIPMENT_INDEX     1



@interface SearchViewController () {
    UITableViewCell *editingCell;
    NSIndexPath *editingIndexPath;
    NSManagedObjectContext *_managedObjectContext;
    BOOL _firstLoad;
}

@property (nonatomic, strong) IBOutlet SwipeTableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segment;

@property (nonatomic, strong) NSMutableArray *genericsArray;
@property (nonatomic, strong) NSMutableArray *equipmentArray;

#if USE_COREDATA
@property (nonatomic, strong) Generics *selectedGenerics;
#endif

@property (nonatomic, strong) NSMutableArray *searchResults;


@end

@implementation SearchViewController

- (void)initArraysWithTempData
{
    _managedObjectContext = [AppContext sharedAppContext].managedObjectContext;
    
    self.genericsArray = [[NSMutableArray alloc] init];
 
#if !USE_COREDATA
    Generics *generics = nil;
    
    generics = [[Generics alloc] init];
    generics.name = @"Wheelchair";
    generics.numberOfNearby = 3;
    generics.notes = @"1 stationary for two 1 stationary for two";
    [self.genericsArray addObject:generics];
    
    generics = [[Generics alloc] init];
    generics.name = @"Bladder Volume Monitor";
    generics.numberOfNearby = 1;
    generics.notes = @"One in ICU to be returned to Theatres";
    [self.genericsArray addObject:generics];
    
    generics = [[Generics alloc] init];
    generics.name = @"Pump, Infusion Module";
    generics.numberOfNearby = 12;
    generics.notes = @"1 stationary for two .....";
    [self.genericsArray addObject:generics];
    
    Equipment *equipment = nil;
    
    equipment = [[Equipment alloc] init];
    equipment.name = @"INVACARE - ACTION3NG";
    equipment.currentLocation = @"Level 3 Storeroom";
    equipment.serialNumber = @"ASED0-1123";
    [self.equipmentArray addObject:equipment];
    
    equipment = [[Equipment alloc] init];
    equipment.name = @"INVACARE - ACTION3NG";
    equipment.currentLocation = @"Level 3 Storeroom";
    equipment.serialNumber = @"ASED0-1123";
    [self.equipmentArray addObject:equipment];
    
    equipment = [[Equipment alloc] init];
    equipment.name = @"INVACARE - ACTION3NG";
    equipment.currentLocation = @"Level 3 Storeroom";
    equipment.serialNumber = @"ASED0-1123";
    [self.equipmentArray addObject:equipment];
    
    equipment = [[Equipment alloc] init];
    equipment.name = @"INVACARE - ACTION3NG";
    equipment.currentLocation = @"Level 3 Storeroom";
    equipment.serialNumber = @"ASED0-1123";
    [self.equipmentArray addObject:equipment];
#else
    
    
    

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
            
            [self.genericsArray addObject:generics];
        }
    }
#endif
    
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
    
    [self.navigationController.tabBarItem setSelectedImage:[UIImage imageNamed:@"searchicon_selected"]];
    
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    [self.searchDisplayController.searchResultsTableView registerClass:[GenericsTableViewCell class] forCellReuseIdentifier:@"genericscell"];
    [self.searchDisplayController.searchResultsTableView registerClass:[EquipmentTableViewCell class] forCellReuseIdentifier:@"equipmentcell"];
    
    self.genericsArray = [[NSMutableArray alloc] init];
    self.equipmentArray = [[NSMutableArray alloc] init];
    self.searchResults = [[NSMutableArray alloc] init];
    
    // initialize list with temp data for test
    [self initArraysWithTempData];
    
    // set empty view to footer view
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;

    self.tableView.swipeDelegate = self;
    [self.tableView initControls];
    
    _firstLoad = YES;
    
    editingCell = nil;
    editingIndexPath = nil;
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

#pragma mark - table view data source

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView)
        return 1;
    else if (tableView == self.searchDisplayController.searchResultsTableView)
        return 1;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        if (self.segment.selectedSegmentIndex == 0)
            return self.genericsArray.count;
        else
        {
#if !USE_COREDATA
            return self.equipmentArray.count;
#else
            return self.selectedGenerics.equipments.count;
#endif
        }
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView)
        return self.searchResults.count;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        // Generics cell
        if (self.segment.selectedSegmentIndex == 0)
        {
            GenericsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"genericscell"];
            [cell bind:[self.genericsArray objectAtIndex:indexPath.row] type:GenericsCellTypeSearch];
            [cell setEditing:NO];
            [self.tableView setEditing:NO animated:NO];
            return cell;
        }
        else
        {
            EquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipmentcell"];
#if !USE_COREDATA
            [cell bind:[self.equipmentArray objectAtIndex:indexPath.row]];
#else
            [cell bind:[[self.selectedGenerics.equipments allObjects] objectAtIndex:indexPath.row] type:EquipmentCellTypeSearch];
#endif
            return cell;
        }
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        // Generics cell
        if (self.segment.selectedSegmentIndex == 0)
        {
            GenericsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"genericscell" forIndexPath:indexPath];
            [cell bind:[self.searchResults objectAtIndex:indexPath.row] type:GenericsCellTypeSearch];
            return cell;
        }
        else
        {
            EquipmentTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"equipmentcell"];
#if !USE_COREDATA
            [cell bind:[self.searchResults objectAtIndex:indexPath.row]];
#else
            [cell bind:[self.searchResults objectAtIndex:indexPath.row] type:EquipmentCellTypeSearch];
#endif
            return cell;
        }
    }
    return nil;
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
    else if (tableView == self.searchDisplayController.searchResultsTableView)
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

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        if (self.segment.selectedSegmentIndex == 0)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self.segment setSelectedSegmentIndex:1];
#if USE_COREDATA
                self.selectedGenerics = [self.genericsArray objectAtIndex:indexPath.row];
#endif
                //[self.segment sendActionsForControlEvents:UIControlEventValueChanged];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
            }];
        }
        else
        {
#if USE_COREDATA
            
            if (self.selectedGenerics)
            {
                
                Equipment *equipment = [[self.selectedGenerics.equipments allObjects] objectAtIndex:indexPath.row];
                
                // push new tab bar
                EquipmentTabBarController *equipTabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"EquipmentTabBarController"];
                equipTabBar.equipment = equipment;

                // set animation style
                equipTabBar.modalTransitionStyle = [UIManager detailModalTransitionStyle];
                [self presentViewController:equipTabBar animated:YES completion:nil];

            }
#endif
        }
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        if (self.segment.selectedSegmentIndex == 0)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self.searchDisplayController setActive:NO animated:YES];
                [self.segment setSelectedSegmentIndex:1];
#if USE_COREDATA
                self.selectedGenerics = [self.genericsArray objectAtIndex:indexPath.row];
#endif
                //[self.segment sendActionsForControlEvents:UIControlEventValueChanged];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
            }];
        }
        else
        {
            // open detail tab view
        
            Equipment *equipment = [self.searchResults objectAtIndex:indexPath.row];
            
            // push new tab bar
            EquipmentTabBarController *equipTabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"EquipmentTabBarController"];
            equipTabBar.equipment = equipment;
            
            // set animation style
            equipTabBar.modalTransitionStyle = [UIManager detailModalTransitionStyle];
            [self presentViewController:equipTabBar animated:YES completion:nil];
        }
    }
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // generics
    if (self.segment.selectedSegmentIndex == 0)
        [self updateFilteredContentOfGenericsForName:searchString];
    else
        [self updateFilteredContentOfEquipmentForName:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSString *searchString = [self.searchDisplayController.searchBar text];
    
    // generics
    if (self.segment.selectedSegmentIndex == 0)
        [self updateFilteredContentOfGenericsForName:searchString];
    else
        [self updateFilteredContentOfEquipmentForName:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    controller.searchBar.showsCancelButton = YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    controller.searchBar.showsCancelButton = NO;
}

#pragma mark - Content filtering
- (void)updateFilteredContentOfGenericsForName:(NSString *)name
{
    if ((name == nil) || [name length] == 0)
    {
        self.searchResults = [self.genericsArray mutableCopy];
        return;
    }
    
    // remove all objects
    [self.searchResults removeAllObjects];

    
    // search with name
    for (Generics *generics in self.genericsArray)
	{
        NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
        NSRange nameRange = NSMakeRange(0, generics.name.length);
        NSRange foundRange = [generics.name rangeOfString:name options:searchOptions range:nameRange];
        if (foundRange.length > 0)
        {
            [self.searchResults addObject:generics];
        }
	}
}

- (void)updateFilteredContentOfEquipmentForName:(NSString *)name
{
    if ((name == nil) || [name length] == 0)
    {
        if (self.selectedGenerics)
            self.searchResults = [[self.selectedGenerics.equipments allObjects] mutableCopy];
        else
            self.searchResults = [[NSMutableArray alloc] init];
        return;
    }
    
    // remove all objects
    [self.searchResults removeAllObjects];
    
    // search with name
#if !USE_COREDATA
    for (Equipment *equipment in self.genericsArray)
	{
        NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
        NSRange nameRange = NSMakeRange(0, equipment.name.length);
        NSRange foundRange = [equipment.name rangeOfString:name options:searchOptions range:nameRange];
        if (foundRange.length > 0)
        {
            [self.searchResults addObject:equipment];
        }
	}
#else
    if (self.selectedGenerics)
    {
        for (Equipment *equipment in self.selectedGenerics.equipments)
        {
            NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
            NSRange nameRange = NSMakeRange(0, equipment.name.length);
            NSRange foundRange = [equipment.name rangeOfString:name options:searchOptions range:nameRange];
            if (foundRange.length > 0)
            {
                [self.searchResults addObject:equipment];
            }
        }
    }
#endif
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
    
//    ContactCell *cCell = (ContactCell *)cell;
//    
//    [cCell setEditor:editing animate:animate];
//    
//    _editingCount += editing ? 1 : -1;
//    if(_editingCount < 0) _editingCount = 0;
//    
//    if(editing){
//        _editingCell = cCell;
//        _editingIndexPath = indexPath;
//        _swipeLeftRecognizer.enabled = NO;
//    } else if(_editingCount == 0){
//        _editingCell = nil;
//        _editingIndexPath = nil;
//        _swipeLeftRecognizer.enabled = YES;
//    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
        return YES;
    return NO;
}

#pragma mark - bar positioning delegate
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTop;
}

#pragma mark - segment action
- (IBAction)onSegmentIndexChanged:(id)sender
{
    // reload data
    if (editingCell)
        [self.tableView setEditing:NO atIndexPath:editingIndexPath cell:editingCell];
    [self.tableView reloadData];
}




@end
