//
//  DetailBaseTableViewController.h
//  WhereNow
//
//  Created by Xiaoxue Han on 07/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EquipmentTabBarController.h"

@interface DetailBaseTableViewController : UITableViewController

@property (nonatomic, retain) id<EquipmentDetailMenuDelegate> delegate;

- (void)didPagedDevice;

@end
