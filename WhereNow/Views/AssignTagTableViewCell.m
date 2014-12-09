//
//  AssignTagTableViewCell.m
//  WhereNow
//
//  Created by Admin on 12/6/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "AssignTagTableViewCell.h"

@implementation AssignTagInfo

@end

@interface AssignTagTableViewCell()

@property (nonatomic, weak) IBOutlet UIImageView *imgSelected;
@property (nonatomic, weak) IBOutlet UILabel *labelDeviceName;
@property (nonatomic, weak) IBOutlet UIImageView *imgSignal;

@end

@implementation AssignTagTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTagCell:(AssignTagInfo *) tagCell
{
    _tagCell = tagCell;
    
    if (_tagCell == nil)
    {
        self.imgSelected.image = [UIImage imageNamed:@"icon_checkmark_nonchecked"];
        [self.labelDeviceName setText:@""];
        self.imgSignal.image = [UIImage imageNamed:@"signal_0"];
        return;
    }
    else
    {
        int nChecked = tagCell.checkmark;
        if (nChecked == 0)
            self.imgSelected.image = [UIImage imageNamed:@"icon_checkmark_nonchecked"];
        else
            self.imgSelected.image = [UIImage imageNamed:@"icon_checkmark_checked"];
        
        self.labelDeviceName.text = tagCell.tagname;

        int nSignal = tagCell.signal;
        nSignal = 3;
        NSString* imgName = [NSString stringWithFormat:@"signal_%d", nSignal];
        self.imgSignal.image = [UIImage imageNamed:imgName];
    }
    
    return;
}

@end
