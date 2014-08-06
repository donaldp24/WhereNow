//
//  EquipmentTableViewCell.h
//  WhereNow
//
//  Created by Xiaoxue Han on 31/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Equipment.h"

typedef enum {
    EquipmentCellTypeSearch = 0,
    EquipmentCellTypeFavorites
} EquipmentCellType;

@interface EquipmentTableViewCell : UITableViewCell

@property (nonatomic, strong) Equipment *equipment;
@property (assign, nonatomic) BOOL editor;
@property (nonatomic) EquipmentCellType cellType;

- (void)bind:(Equipment *)equipment type:(EquipmentCellType)cellType;
-(void)setEditor:(BOOL)editor;

@end
