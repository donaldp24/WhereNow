//
//  FavoritesViewController.h
//  WhereNow
//
//  Created by Xiaoxue Han on 01/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericsTableViewCell.h"
#import "EquipmentTableViewCell.h"

@interface FavoritesViewController : UIViewController <UITableViewDataSource,
    UITableViewDelegate,
GenericsTableViewCellDelegate,
EquipmentTableViewCellDelegate
>

@end
