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

@interface RecentViewController () <SwipeTableViewDelegate> {
    NSManagedObjectContext *_managedObjectContext;
    UITableViewCell *editingCell;
    NSIndexPath *editingIndexPath;
    BOOL _firstLoad;
}

@property (nonatomic, weak) IBOutlet UISegmentedControl *segment;
@property (nonatomic, weak) IBOutlet SwipeTableView *tableView;

@property (nonatomic, strong) NSMutableArray *recentGenericsArray;
@property (nonatomic, strong) NSMutableArray *recentEquipmentArray;
@property (nonatomic, strong) Generics *selectedGenerics;

@end

@implementation RecentViewController

- (void)loadData
{
    _managedObjectContext = [AppContext sharedAppContext].managedObjectContext;
    
    self.recentGenericsArray = [[NSMutableArray alloc] init];
    
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
            
            [self.recentGenericsArray addObject:generics];
        }
    }
    
    self.recentEquipmentArray = [[NSMutableArray alloc] init];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segment.selectedSegmentIndex == 0)
        return self.recentGenericsArray.count;
    else
    {
        if (self.selectedGenerics != nil)
            return self.selectedGenerics.equipments.count;
        else
            return self.recentEquipmentArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segment.selectedSegmentIndex == 0)
    {
        GenericsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"genericscell"];
        [cell bind:[self.recentGenericsArray objectAtIndex:indexPath.row] type:GenericsCellTypeFavorites];
        [cell setEditing:NO];
        [self.tableView setEditing:NO animated:NO];
        return cell;
    }
    else
    {
        EquipmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"equipmentcell"];
        if (self.selectedGenerics != nil)
            [cell bind:[[self.selectedGenerics.equipments allObjects] objectAtIndex:indexPath.row] type:EquipmentCellTypeFavorites];
        else
            [cell bind:[self.recentEquipmentArray objectAtIndex:indexPath.row] type:EquipmentCellTypeFavorites];
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
    if (self.segment.selectedSegmentIndex == 0)
    {
        [UIView animateWithDuration:0.3 animations:^{
            [self.segment setSelectedSegmentIndex:1];
            self.selectedGenerics = [self.recentGenericsArray objectAtIndex:indexPath.row];
            //[self.segment sendActionsForControlEvents:UIControlEventValueChanged];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
        }];
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
            equipment = [self.recentEquipmentArray objectAtIndex:indexPath.row];
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

@end
