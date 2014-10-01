//
//  CommonEquipmentTableViewCell.m
//  WhereNow
//
//  Created by Xiaoxue Han on 08/09/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "CommonEquipmentTableViewCell.h"
#import "ServerManager.h"
#import "ModelManager.h"
#import "EquipmentImage.h"
#import "AppContext.h"
#import "UserContext.h"

#define kButtonWidth    (75.0f)
#define kHeightForCell  (92.0f);

@interface CommonEquipmentTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UILabel *lblLocation;
@property (nonatomic, weak) IBOutlet UILabel *lblSn;

@property (nonatomic, weak) IBOutlet UIImageView *ivStatus;
@property (nonatomic, weak) IBOutlet UIImageView *ivImg;

@property (nonatomic, weak) IBOutlet UIButton *btnFavorites;
@property (nonatomic, weak) IBOutlet UIButton *btnLocate;
@property (nonatomic, weak) IBOutlet UIButton *btnDelete;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftConstraintOfView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftConstraintOfBtnFavorites;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftConstraintOfBtnLocate;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftConstraintOfBtnDelete;

@end

@implementation CommonEquipmentTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bind:(Equipment *)equipment generic:(Generic *)generic type:(CommonEquipmentCellType)cellType
{
    self.equipment = equipment;
    self.generic = generic;
    self.cellType = cellType;
    
    self.lblName.text = [NSString stringWithFormat:@"%@-%@", equipment.manufacturer_name, equipment.model_name_no] ;
    
    // location name = parent location name + current location name
    if (![equipment.current_location_parent_name isEqualToString:@""])
        self.lblLocation.text = [NSString stringWithFormat:@"%@ %@", equipment.current_location_parent_name, equipment.current_location];
    else
        self.lblLocation.text = [NSString stringWithFormat:@"%@", equipment.current_location];
    
    self.lblSn.text = [NSString stringWithFormat:@"SN : %@", equipment.serial_no];
    
    // favourites icon
    if ([equipment.isfavorites boolValue])
        [self.btnFavorites setImage:[UIImage imageNamed:@"favoriteicon_favorited"] forState:UIControlStateNormal];
    else
        [self.btnFavorites setImage:[UIImage imageNamed:@"favoriteicon"] forState:UIControlStateNormal];
    
    // near me icon
    if ([equipment.islocating boolValue])
        [self.btnLocate setImage:[UIImage imageNamed:@"nearmeicon_located"] forState:UIControlStateNormal];
    else
        [self.btnLocate setImage:[UIImage imageNamed:@"nearmeicon"] forState:UIControlStateNormal];
    
    // set image
    //[[ServerManager sharedManager] setImageContent:self.ivImg urlString:equipment.equipment_file_location];
    [EquipmentImage setModelImageOfEquipment:_equipment toImageView:self.ivImg completed:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self layoutIfNeeded];
        });
    }];
    
    
    // set status image
    if ([equipment.equipment_alert_icon_id intValue] == 0)
        self.ivStatus.image = [UIImage imageNamed:@"status_green"];
    else if ([equipment.equipment_alert_icon_id intValue] == 1)
        self.ivStatus.image = [UIImage imageNamed:@"status_orange"];
    else
        self.ivStatus.image = [UIImage imageNamed:@"status_red"];
    
    _editor = NO;
    
    self.leftConstraintOfView.constant = 0.f;
    
    switch (self.cellType) {
        case CommonEquipmentCellTypeSearch:
        case CommonEquipmentCellTypeRecent:
        case CommonEquipmentCellTypeNearme:
            self.leftConstraintOfBtnFavorites.constant = 0;
            self.btnFavorites.hidden = NO;
            self.leftConstraintOfBtnLocate.constant = kButtonWidth;
            self.btnLocate.hidden = NO;
            
            self.btnDelete.hidden = YES;
            break;
            
        case CommonEquipmentCellTypeFavorites:
            if (self.generic == nil)
            {
                self.leftConstraintOfBtnDelete.constant = 0;
                self.btnDelete.hidden = NO;
                
                self.leftConstraintOfBtnLocate.constant = kButtonWidth;
                self.btnLocate.hidden = NO;
            }
            else
            {
                self.btnDelete.hidden = YES;
                
                self.leftConstraintOfBtnLocate.constant = 0;
                self.btnLocate.hidden = NO;
            }
            
            self.btnFavorites.hidden = YES;
            break;
        default:
            break;
    }
    
    
    
    [self layoutIfNeeded];
}

- (void)setEditor:(BOOL)editor
{
    [self setEditor:editor animate:YES];
}



- (void)setEditor:(BOOL)editor animate:(BOOL)animate
{
    if (editor == _editor)
        return;
    
    _editor = editor;
    
    if (_editor)
    {
        switch (self.cellType) {
            case CommonEquipmentCellTypeSearch:
            case CommonEquipmentCellTypeRecent:
            case CommonEquipmentCellTypeNearme:
                self.leftConstraintOfView.constant = -kButtonWidth * 2;
                break;
            case CommonEquipmentCellTypeFavorites:
                if (self.generic == nil)
                    self.leftConstraintOfView.constant = -kButtonWidth * 2;
                else
                    self.leftConstraintOfView.constant = -kButtonWidth;

            default:
                break;
        }
    }
    else
    {
        self.leftConstraintOfView.constant = 0;
    }
    
    if (animate)
    {
        [UIView animateWithDuration:0.2 animations:^() {
            [self.contentView layoutIfNeeded];
        }];
    }
    else
        [self.contentView layoutIfNeeded];
}

- (IBAction)onFavorite:(id)sender
{
    self.equipment.isfavorites = @(YES);
    [[ModelManager sharedManager] saveContext];
    
    [self.btnFavorites setImage:[UIImage imageNamed:@"favoriteicon_favorited"] forState:UIControlStateNormal];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onEquipmentFavorite:)])
        [self.delegate onEquipmentFavorite:self.equipment];
}

- (IBAction)onLocate:(id)sender
{
    NSString *utoken = [AppContext sharedAppContext].cleanDeviceToken;
    if ([self.equipment.islocating boolValue])
    {
        self.equipment.islocating = @(NO);
        [[ServerManager sharedManager] cancelEquipmentWatch:@[self.equipment.equipment_id] token:utoken userId:[UserContext sharedUserContext].userId success:^() {
            NSLog(@"cancelEquipmentWatch success : %@", self.equipment.equipment_id);
        } failure:^(NSString *msg) {
            NSLog(@"cancelEquipmentWatch failure : %@", self.equipment.equipment_id);
        }];
    }
    else
    {
        self.equipment.islocating = @(YES);
        [[ServerManager sharedManager] createEquipmentWatch:@[self.equipment.equipment_id] token:utoken userId:[UserContext sharedUserContext].userId success:^() {
            NSLog(@"createEquipmentWatch success : %@", self.equipment.equipment_id);
        } failure:^(NSString *msg) {
            NSLog(@"createEquipmentWatch failure : %@", self.equipment.equipment_id);
        }];
    }
    [[ModelManager sharedManager] saveContext];
    
    // near me icon
    if ([self.equipment.islocating boolValue])
        [self.btnLocate setImage:[UIImage imageNamed:@"nearmeicon_located"] forState:UIControlStateNormal];
    else
        [self.btnLocate setImage:[UIImage imageNamed:@"nearmeicon"] forState:UIControlStateNormal];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onEquipmentLocate:)])
        [self.delegate onEquipmentLocate:self.equipment];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocatingChanged object:nil];
}

- (IBAction)onDelete:(id)sender
{
    //[[ModelManager sharedManager].managedObjectContext deleteObject:self.equipment];
    self.equipment.isfavorites = @(NO);
    [[ModelManager sharedManager] saveContext];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onEquipmentDelete:)])
        [self.delegate onEquipmentDelete:self.equipment];
    
}

#pragma mark - utility
- (CGFloat)heightForCell
{
    return kHeightForCell;
}

@end
