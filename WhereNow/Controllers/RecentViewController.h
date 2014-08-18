//
//  RecentViewController.h
//  WhereNow
//
//  Created by Xiaoxue Han on 02/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericsTableViewCell.h"
#import "EquipmentTableViewCell.h"

@interface RecentViewController : UIViewController <UITableViewDataSource,
    UITableViewDelegate,
    GenericsTableViewCellDelegate,
    EquipmentTableViewCellDelegate
>


@end
