//
//  EquipmentTableViewCell.m
//  WhereNow
//
//  Created by Xiaoxue Han on 31/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "EquipmentTableViewCell.h"
#import "UIManager.h"
#import "Config.h"
#import "ModelManager.h"

#define kButtonWidth        75.0

@interface EquipmentTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UILabel *lblLocation;
@property (nonatomic, weak) IBOutlet UILabel *lblSn;

@property (nonatomic, weak) IBOutlet UIImageView *ivStatus;
@property (nonatomic, weak) IBOutlet UIImageView *ivImg;

@property (nonatomic, weak) IBOutlet UIView *shadowView;

@end

@implementation EquipmentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected)
        self.shadowView.backgroundColor = [UIManager cellHighlightColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
        self.shadowView.backgroundColor = [UIManager cellHighlightColor];
}

- (void)bind:(Equipment *)equipment generic:(Generic *)generic type:(EquipmentCellType)cellType
{
    self.equipment = equipment;
    self.generic = generic;
    self.cellType = cellType;
    
    self.lblName.text = [NSString stringWithFormat:@"%@-%@", equipment.manufacturer_name, equipment.model_name_no] ;
    self.lblLocation.text = equipment.current_location;
    self.lblSn.text = [NSString stringWithFormat:@"SN : %@", equipment.serial_no];
    
    if ([equipment.isfavorites boolValue])
        [self.btnFavorites setImage:[UIImage imageNamed:@"favoriteicon_favorited"] forState:UIControlStateNormal];
    else
        [self.btnFavorites setImage:[UIImage imageNamed:@"favoriteicon"] forState:UIControlStateNormal];
    
    CGRect frame = self.shadowView.frame;
    frame = CGRectMake(frame.origin.x, frame.origin.y, self.contentView.frame.size.width, frame.size.height);
    self.shadowView.frame = frame;
    
    _editor = NO;
    
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
    
#if !USE_SHIFT_ANIMATION_FOR_EDITING_CELL
    void (^updateConstraintsForEditing)(void) = ^void {
        __block CGFloat width = self.frame.size.width;
        if (self.editor) {
            if (self.generic && self.cellType == EquipmentCellTypeFavorites)
                width = self.contentView.frame.size.width - kButtonWidth;
            else
                width = self.contentView.frame.size.width - kButtonWidth * 2;
        }
        //[self.shadeView mas_updateConstraints:^(MASConstraintMaker *make) {
        //    make.left.equalTo( self.left).offset(offset);
        //}];
        
        CGRect frame = self.shadowView.frame;
        self.shadowView.frame = CGRectMake(frame.origin.x, frame.origin.y, width, frame.size.height);
        
        [self layoutIfNeeded];
    };
#else
    void (^updateConstraintsForEditing)(void) = ^void {
        __block CGFloat offset = 0;
        if (self.editor) {
            offset = -170;
        }
        //[self.shadeView mas_updateConstraints:^(MASConstraintMaker *make) {
        //    make.left.equalTo( self.left).offset(offset);
        //}];
        
        CGRect frame = self.shadowView.frame;
        self.shadowView.frame = CGRectMake(offset, frame.origin.y, frame.size.width, frame.size.height);
        
        [self layoutIfNeeded];
    };
#endif
    
    if (animate) {
        [UIView animateWithDuration:.2f animations:updateConstraintsForEditing];
    } else {
        updateConstraintsForEditing();
    }
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(onEquipmentLocate:)])
        [self.delegate onEquipmentLocate:self.equipment];
}

- (IBAction)onDelete:(id)sender
{
    //[[ModelManager sharedManager].managedObjectContext deleteObject:self.equipment];
    self.equipment.isfavorites = @(NO);
    [[ModelManager sharedManager] saveContext];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onEquipmentDelete:)])
        [self.delegate onEquipmentDelete:self.equipment];
        
}

@end
