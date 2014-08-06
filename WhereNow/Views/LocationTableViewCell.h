//
//  LocationTableViewCell.h
//  WhereNow
//
//  Created by Xiaoxue Han on 04/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@interface LocationTableViewCell : UITableViewCell

@property (nonatomic, strong) Location *location;

- (void)bind:(Location *)location;
-(void)setEditor:(BOOL)editor;

@end
