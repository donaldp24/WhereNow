//
//  RightViewController.m
//  WhereNow
//
//  Created by Admin on 12/18/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "RightViewController.h"
#import "ModelManager.h"
#import "UIManager.h"
#import "RightDetailViewController.h"

@interface RightViewController () <RightViewDelegate>

@property (nonatomic, retain) NSMutableArray *arrData;
@property (nonatomic, retain) NSMutableArray *arrValue;

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@end

@implementation RightViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.arrData = [[NSMutableArray alloc] init];
    self.arrValue = [[NSMutableArray alloc] init];
    
    
    [[ModelManager sharedManager] initWithDelegate:self];
}

- (void) didGetDevicesInfo: (NSString *)regionName indevices:(NSString *) indevices withindevices:(NSString *) withindevices requesteddevices:(NSString *) requesteddevices outdevices:(NSString *)outdevices
{
    [self.arrValue addObject:indevices];
    [self.arrValue addObject:withindevices];
    [self.arrValue addObject:requesteddevices];
    [self.arrValue addObject:outdevices];
    
    [self.arrData addObject:[NSString stringWithFormat:@"DEVICES IN %@", regionName]];
    [self.arrData addObject:[NSString stringWithFormat:@"DEVICES ROAMING WITHIN %@", regionName]];
    [self.arrData addObject:@"REQUESTED TO BE RETURNED"];
    [self.arrData addObject:[NSString stringWithFormat:@"DEVICES OUT OF %@", regionName]];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
    
    return;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 4;
    
    return 4;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0;
    
    return 0;
}

- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fRowHeight = 143.0f;
    
    return fRowHeight;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rightviewcell"];
    UILabel *lblValue = (UILabel*)[cell viewWithTag:100];
    UILabel *lblData = (UILabel*)[cell viewWithTag:101];
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0:
                if (self.arrData.count != 0)
                {
                    [lblValue setText:[self.arrValue objectAtIndex:indexPath.row]];
                    [lblData setText:[self.arrData objectAtIndex:indexPath.row]];
                }
                else
                {
                    [lblValue setText:@"-"];
                    [lblData setText:@"-"];
                }
                break;
            case 1:
                if (self.arrData.count != 0)
                {
                    [lblValue setText:[self.arrValue objectAtIndex:indexPath.row]];
                    [lblData setText:[self.arrData objectAtIndex:indexPath.row]];
                }
                else
                {
                    [lblValue setText:@"-"];
                    [lblData setText:@"-"];
                }
                break;
            case 2:
                if (self.arrData.count != 0)
                {
                    [lblValue setText:[self.arrValue objectAtIndex:indexPath.row]];
                    [lblData setText:[self.arrData objectAtIndex:indexPath.row]];
                }
                else
                {
                    [lblValue setText:@"-"];
                    [lblData setText:@"-"];
                }
                [lblValue setTextAlignment:NSTextAlignmentCenter];
                [lblValue setTextColor:[UIColor colorWithRed:1.0f green:0.f blue:0.f alpha:1.0]];
                break;
            case 3:
                if (self.arrData.count != 0)
                {
                    [lblValue setText:[self.arrValue objectAtIndex:indexPath.row]];
                    [lblData setText:[self.arrData objectAtIndex:indexPath.row]];
                }
                else
                {
                    [lblValue setText:@"-"];
                    [lblData setText:@"-"];
                }
                break;
            default:
                break;
        }
    }
    
    return cell;
}

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.arrData.count)
        return;
    
    UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightDetailNavigationController"];
    RightDetailViewController *controller = (RightDetailViewController *)navController.viewControllers[0];
    [controller setNKind:indexPath.row];
    
    [self presentViewController:navController animated:YES completion:nil];
    
    return;
}

@end
