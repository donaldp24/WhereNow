//
//  RightDetailViewController.m
//  WhereNow
//
//  Created by Admin on 1/13/15.
//  Copyright (c) 2015 nicholas. All rights reserved.
//

#import "RightDetailViewController.h"
#import "UIManager.h"
#import "ModelManager.h"
#import "UserContext.h"
#import "EquipmentImage.h"
#import "EquipmentTabBarController.h"
#import "CommonEquipmentTableViewCell.h"

@interface RightDetailViewController ()<CommonEquipmentTableViewCellDelegate>
{
    UIBarButtonItem *_backButton;
}

@property (nonatomic, strong) NSMutableArray *arrExistEquip;

@end

@implementation RightDetailViewController

@synthesize nKind;

- (id) init
{
    self = [super init];
    
    if (self)
    {
        self.nKind = 0;
        self.arrExistEquip = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backicon"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = _backButton;
    
    
    NSMutableArray *arrayData = [[ModelManager sharedManager] retrieveEquipmentsWithHasBeacon:YES];
    
    NSString *currLocName = [UserContext sharedUserContext].currentLocation;
    int currLocId = [[UserContext sharedUserContext].currentLocationId intValue];
    switch (self.nKind) {
        case 0:
            currLocName = [NSString stringWithFormat:@"DEVICES IN %@", currLocName];
            break;
        case 1:
            currLocName = [NSString stringWithFormat:@"DEVICES ROAMING WITHIN %@", currLocName];
            break;
        case 2:
            currLocName = @"REQUESTED TO BE RETURNED";
            break;
        case 3:
            currLocName = [NSString stringWithFormat:@"DEVICES OUT OF %@", currLocName];
            break;
        default:
            currLocName = @"";
            break;
    }
    self.title = currLocName;
    
    self.arrExistEquip = [[NSMutableArray alloc] init];
    for (int i = 0; i < [arrayData count]; i++) {
        Equipment *equipment = (Equipment *)[arrayData objectAtIndex:i];
        
        int equipHomeLocId = [equipment.home_location_id intValue];
        int equipCurLocId = [equipment.current_location_id intValue];
        
        switch (self.nKind) {
            case 0:
            {
                if (currLocId == equipCurLocId)
                    [self.arrExistEquip addObject:equipment];
            }
                break;
            case 1:
            {
                if (currLocId != equipHomeLocId && currLocId == equipCurLocId)
                    [self.arrExistEquip addObject:equipment];
            }
                break;
            case 2:
                break;
            case 3:
            {
                if (currLocId == equipHomeLocId && currLocId != equipCurLocId)
                    [self.arrExistEquip addObject:equipment];
            }
                break;
            default:
                break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) onBack:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrExistEquip.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.f;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 91.f;
}

-(UIView *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"RightDetailCell"];
    
    UIImageView *imagePhoto = (UIImageView *)[cell viewWithTag:100];
    UIImageView *imageIcon = (UIImageView *)[cell viewWithTag:101];
    UILabel *labelName = (UILabel *)[cell viewWithTag:102];
    UILabel *labelLevel = (UILabel *)[cell viewWithTag:102];
    UILabel *labelSN = (UILabel *)[cell viewWithTag:102];
    
    Equipment *equip = (Equipment *)[self.arrExistEquip objectAtIndex:indexPath.row];
    if (equip != nil)
    {
        labelName.text = [ModelManager getEquipmentName:equip];
        
        // location name = parent location name + current location name
        if (![equip.current_location_parent_name isEqualToString:@""])
            labelLevel.text = [NSString stringWithFormat:@"%@ %@", equip.current_location_parent_name, equip.current_location];
        else
            labelLevel.text = [NSString stringWithFormat:@"%@", equip.current_location];
        
        labelSN.text = [NSString stringWithFormat:@"SN : %@", equip.serial_no];
        
        // set status image
        if ([equip.equipment_alert_icon_id intValue] == 0)
            imageIcon.image = [UIImage imageNamed:@"status_green"];
        else if ([equip.equipment_alert_icon_id intValue] == 1)
            imageIcon.image = [UIImage imageNamed:@"status_orange"];
        else
            imageIcon.image = [UIImage imageNamed:@"status_red"];
        
        [EquipmentImage setModelImageOfEquipment:equip toImageView:imagePhoto completed:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [cell layoutIfNeeded];
            });
        }];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EquipmentTabBarController *equipTabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"EquipmentTabBarController"];
    equipTabBar.equipment = [self.arrExistEquip objectAtIndex:indexPath.row];
    
    equipTabBar.modalTransitionStyle = [UIManager detailModalTransitionStyle];
    equipTabBar.providesPresentationContextTransitionStyle = YES;
    equipTabBar.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:equipTabBar animated:YES completion:nil];
}

@end
