//
//  EquipmentTableViewCell.h
//  WhereNow
//
//  Created by Xiaoxue Han on 31/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Equipment.h"
#import "Generic.h"

typedef enum {
    EquipmentCellTypeSearch = 0,
    EquipmentCellTypeFavorites
} EquipmentCellType;

@protocol EquipmentTableViewCellDelegate <NSObject>

@optional
- (void)onEquipmentDelete:(Equipment *)equipment;
- (void)onEquipmentFavorite:(Equipment *)equipment;
- (void)onEquipmentLocate:(Equipment *)equipment;

@end

@interface EquipmentTableViewCell : UITableViewCell

@property (nonatomic, strong) Equipment *equipment;
@property (nonatomic, strong) Generic *generic;

@property (assign, nonatomic) BOOL editor;
@property (nonatomic) EquipmentCellType cellType;

@property (nonatomic, retain) id<EquipmentTableViewCellDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIButton *btnFavorites;
// delete button will hide when it is remove
@property (nonatomic, weak) IBOutlet UIButton *btnDelete;


- (void)bind:(Equipment *)equipment generic:(Generic *)generic type:(EquipmentCellType)cellType;
-(void)setEditor:(BOOL)editor;
- (void)setEditor:(BOOL)editor animate:(BOOL)animate;

@end
