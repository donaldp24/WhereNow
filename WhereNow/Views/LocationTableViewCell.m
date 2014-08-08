//
//  LocationTableViewCell.m
//  WhereNow
//
//  Created by Xiaoxue Han on 04/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "LocationTableViewCell.h"

@interface LocationTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UILabel *lblCount;
@property (nonatomic, weak) IBOutlet UILabel *lblNote;

@end

@implementation LocationTableViewCell

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
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];

}

- (void)bind:(GenericLocation *)genericLocation
{
    self.genericLocation = genericLocation;
    
    self.lblName.text = genericLocation.location_name;
    
    [self layoutIfNeeded];
}

- (void)setEditor:(BOOL)editor
{
    //
}


@end
