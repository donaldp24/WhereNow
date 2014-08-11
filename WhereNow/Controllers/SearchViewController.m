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
#import "GenericLocation.h"
#import "ModelManager.h"
#import "ServerManager.h"
#import "UserContext.h"
#import "LocationTableViewCell.h"

#define GENERICS_INDEX      0
#define EQUIPMENT_INDEX     1

@interface SearchViewController () {
    UITableViewCell *editingCell;
    NSIndexPath *editingIndexPath;
    BOOL _firstLoad;
    BOOL _isSearching;

    NSMutableArray *_expandingLocationArray;

}

@property (nonatomic, strong) IBOutlet SwipeTableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segment;

@property (nonatomic, strong) NSMutableArray *genericsArray;
@property (nonatomic, strong) NSMutableArray *equipmentArray;

#if USE_COREDATA
@property (nonatomic, strong) Generic *selectedGenerics;
#endif

@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, strong) UISearchBar *customSearchBar;


@end

@implementation SearchViewController

- (void)loadData
{
    ModelManager *manager = [ModelManager sharedManager];
    
    self.genericsArray = [manager retrieveGenerics];
    self.equipmentArray = [manager retrieveEquipmentsWithBeacon:YES];
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
    
    
    self.genericsArray = [[NSMutableArray alloc] init];
    self.equipmentArray = [[NSMutableArray alloc] init];
    self.searchResults = [[NSMutableArray alloc] init];
    _expandingLocationArray = [[NSMutableArray alloc] init];
    
    // load data
    [self loadData];
    
    // set empty view to footer view
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;

    self.tableView.swipeDelegate = self;
    [self.tableView initControls];
    
    _firstLoad = YES;
    _isSearching = NO;
    
    editingCell = nil;
    editingIndexPath = nil;
    
    // create search bar on navigation bar
    UISearchBar *searchBar = [UISearchBar new];//[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    [searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    [searchBar setPlaceholder:@"Search"];
    searchBar.delegate = self;
    self.customSearchBar = searchBar;
    [self.navigationItem setTitleView:searchBar];
    
    // get data from server
    [[ServerManager sharedManager] getGenerics:[UserContext sharedUserContext].sessionId userId:[UserContext sharedUserContext].userId success:^() {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
            
            
            // reload data
            [self loadData];
            
            self.selectedGenerics = nil;
            if (editingCell)
                [self.tableView setEditing:NO atIndexPath:editingIndexPath cell:editingCell];
            
            editingIndexPath = nil;
            editingCell = nil;
            
            [_expandingLocationArray removeAllObjects];
            
            if (_isSearching)
            {
                if (self.segment.selectedSegmentIndex == 0)
                    [self updateFilteredContentOfGenericsForName:_customSearchBar.text];
                else
                    [self updateFilteredContentOfEquipmentForName:_customSearchBar.text];
            }
            
            [self.tableView reloadData];
        }];
    } failure:^(NSString *failureMsg) {
        //
    }];
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
        
        [self.tableView reloadData];
    }
    
    _firstLoad = NO;
 
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShowing:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHiding:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    
    if (![self.customSearchBar.text isEqualToString:@""])
        [self.customSearchBar becomeFirstResponder];
}

#pragma mark - table view data source

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

- (NSArray *)dataForTable:(UITableView *)tableView
{
    if (_isSearching)
        return self.searchResults;
    else
    {
        if (self.segment.selectedSegmentIndex == 0)
            return self.genericsArray;
        else
        {
            if (self.selectedGenerics != nil)
                return [[ModelManager sharedManager] equipmentsForGeneric:self.selectedGenerics withBeacon:YES];
            else
                return self.equipmentArray;
        }
    }
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
    if (tableView == self.tableView)
        return 1;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arrayData = [self dataForTable:tableView];

    int count = 0;
    if (arrayData != nil)
        count = arrayData.count;
    count += _expandingLocationArray.count;

    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrayData = [self dataForTable:tableView];
    
    if (tableView == self.tableView)
    {
        // Generics cell
        
        if (self.segment.selectedSegmentIndex == 0)
        {
            if([self isGenericCell:indexPath])
            {
                GenericsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"genericscell"];
                if (indexPath.row <= editingIndexPath.row)
                    [cell bind:[arrayData objectAtIndex:indexPath.row] type:GenericsCellTypeSearch];
                else
                    [cell bind:[arrayData objectAtIndex:(indexPath.row - _expandingLocationArray.count)] type:GenericsCellTypeSearch];
                
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
            [cell bind:[arrayData objectAtIndex:indexPath.row] generic:self.selectedGenerics type:EquipmentCellTypeSearch];
            if (editingIndexPath != nil && editingIndexPath.row == indexPath.row)
            {
                editingIndexPath = indexPath;
                editingCell = cell;
                [cell setEditor:YES animate:NO];
            }
            return cell;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arrayData = [self dataForTable:tableView];
    if (tableView == self.tableView)
    {
        if (self.segment.selectedSegmentIndex == 0)
        {
            if ([self isGenericCell:indexPath])
            {
                self.selectedGenerics = [arrayData objectAtIndex:indexPath.row];
                _equipmentArray = [[ModelManager sharedManager] equipmentsForGeneric:self.selectedGenerics withBeacon:YES];
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    [self.segment setSelectedSegmentIndex:1];

                    // cancel searching
                    _isSearching = NO;
                    self.customSearchBar.text = @"";
                    [self.customSearchBar resignFirstResponder];
                    
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
                }];
            }
        }
        else
        {
            Equipment *equipment = [arrayData objectAtIndex:indexPath.row];
            
            // push new tab bar
            EquipmentTabBarController *equipTabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"EquipmentTabBarController"];
            equipTabBar.equipment = equipment;

            // set animation style
            equipTabBar.modalTransitionStyle = [UIManager detailModalTransitionStyle];
            [self presentViewController:equipTabBar animated:YES completion:nil];
        }
    }
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
    for (Generic *generic in self.genericsArray)
	{
        NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
        NSRange nameRange = NSMakeRange(0, generic.generic_name.length);
        NSRange foundRange = [generic.generic_name rangeOfString:name options:searchOptions range:nameRange];
        if (foundRange.length > 0)
        {
            [self.searchResults addObject:generic];
        }
	}
}

- (void)updateFilteredContentOfEquipmentForName:(NSString *)name
{
    if ((name == nil) || [name length] == 0)
    {
        if (self.selectedGenerics)
            self.searchResults = [[ModelManager sharedManager] equipmentsForGeneric:self.selectedGenerics withBeacon:YES];
        else
            self.searchResults = [[NSMutableArray alloc] init];
        return;
    }
    
    // remove all objects
    [self.searchResults removeAllObjects];
    
    // search with name
    if (self.selectedGenerics)
    {
        self.searchResults = [[ModelManager sharedManager] searchEquipmentsWithGenerics:self.selectedGenerics withKeyword:name];
    }
    else
    {
        self.searchResults = [[ModelManager sharedManager] searchEquipmentsWithArray:self.equipmentArray withKeyword:name];
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



#pragma mark - segment action
- (IBAction)onSegmentIndexChanged:(id)sender
{
    self.selectedGenerics = nil;
    if (editingCell)
        [self.tableView setEditing:NO atIndexPath:editingIndexPath cell:editingCell];
    
    editingIndexPath = nil;
    editingCell = nil;
    
    [_expandingLocationArray removeAllObjects];
    
    if (_isSearching)
    {
        if (self.segment.selectedSegmentIndex == 0)
            [self updateFilteredContentOfGenericsForName:_customSearchBar.text];
        else
            [self updateFilteredContentOfEquipmentForName:_customSearchBar.text];
    }
    
    
    [self.tableView reloadData];
}

#pragma mark - searchbar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    NSLog(@"%@", @"searchBar Text Did Begin Editing--\n");
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if ([searchBar.text isEqualToString:@""])
        [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // generics
    if (self.segment.selectedSegmentIndex == 0)
        [self updateFilteredContentOfGenericsForName:searchText];
    else
        [self updateFilteredContentOfEquipmentForName:searchText];
    
    _isSearching = YES;
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _isSearching = NO;
    
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    
    [self.tableView reloadData];
}

#pragma mark Keyboard Methods

- (void)keyboardShowing:(NSNotification *)note
{
    NSNumber *duration = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    /*
    CGRect frame = self.tableView.frame;
    frame.size.height -= 60;
    
    [UIView animateWithDuration:duration.floatValue animations:^{
        //self.logo.alpha = 0.0;
        self.tableView.frame = frame;
        [self.view layoutIfNeeded];
    }];
     */
    
}

- (void)keyboardHiding:(NSNotification *)note
{
    NSNumber *duration = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
   /*
    [UIView animateWithDuration:duration.floatValue animations:^{
        self.logo.alpha = 1.0;
        [self.view layoutIfNeeded];
    }];
    */
}

@end
