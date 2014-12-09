//
//  AssignTagViewController.m
//  WhereNow
//
//  Created by Admin on 12/4/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "AssignTagViewController.h"
#import "AssignTagTableViewCell.h"
#import "SVProgressHUD+WhereNow.h"
#import "UIManager.h"
#import "UserContext.h"

@interface AssignTagViewController () <AssignTagDelegate>
{
    UIBarButtonItem* btnBack;
    int selMinor;
}

@property (nonatomic, retain) ScanManager *scanManager;
@property (weak, nonatomic) IBOutlet UITableView *tableTags;
@property (nonatomic, retain) NSMutableArray *arrBeacons;

@end

@implementation AssignTagViewController

- (void)viewDidLoad {
    
    self.arrBeacons = [NSMutableArray array];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    btnBack = [UIManager defaultBackButton:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = btnBack;
    
    self.scanManager = [ScanManager sharedScanManager];
    self.scanManager.delegateAssign = self;
    
    //SHOW_PROGRESS(@"Please Wait");
    [self.scanManager startAssignMode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didAssignBeaconFound:(NSMutableArray *) arrBeacons;
{
    //[SVProgressHUD dismiss];
    if (arrBeacons == nil)
        return;
    
    [self.arrBeacons removeAllObjects];
    for (int i = 0; i < arrBeacons.count; i++)
    {
        ScannedBeacon *item = (ScannedBeacon *)[arrBeacons objectAtIndex:i];
        int nMinor = [item.beacon.minor intValue];
        
        AssignTagInfo *newInfo = [[AssignTagInfo alloc] init];
        newInfo.minor = nMinor;
        newInfo.tagname = [NSString stringWithFormat:@"%@%d", @"Tag ", nMinor];
        newInfo.checkmark = 0;
        //newInfo.signal = (int)(((-1) * beacon.rssi) / 20);
        newInfo.signal = (int)((-1) * (int)item.beacon.rssi) / 20;
        
        int oldMinor = [[UserContext sharedUserContext].currTagMinor intValue];
        if (nMinor == oldMinor)
        {
            newInfo.checkmark = 1;
        }
        else
            newInfo.checkmark = 0;
        
        [self.arrBeacons addObject:newInfo];
    }
    
    [self.tableTags reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tagcell";
    
    AssignTagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate = self;
    cell.tagCell = [self.arrBeacons objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrBeacons count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (AssignTagInfo *info in self.arrBeacons) {
        info.checkmark = 0;
    }
    
    AssignTagTableViewCell *cell = (AssignTagTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.tagCell.checkmark = 1;
    [UserContext sharedUserContext].currTagMinor = [NSNumber numberWithInt:cell.tagCell.minor];
    
    [tableView reloadData];
}

- (IBAction)onBack :(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:TRUE];
    [self.scanManager stopAssignMode];
    
    return;
}

@end
