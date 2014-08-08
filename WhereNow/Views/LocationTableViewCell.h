//
//  LocationTableViewCell.h
//  WhereNow
//
//  Created by Xiaoxue Han on 04/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericLocation.h"

@interface LocationTableViewCell : UITableViewCell

@property (nonatomic, strong) GenericLocation *genericLocation;

- (void)bind:(GenericLocation *)genericLocation;
-(void)setEditor:(BOOL)editor;

@end
