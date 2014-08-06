//
//  GenericsTableViewCell.h
//  WhereNow
//
//  Created by Xiaoxue Han on 31/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Generics.h"

typedef enum {
    GenericsCellTypeSearch = 0,
    GenericsCellTypeFavorites
} GenericsCellType;

@interface GenericsTableViewCell : UITableViewCell

@property (nonatomic, retain) Generics *generics;
@property (assign, nonatomic) BOOL editor;
@property (nonatomic) GenericsCellType cellType;

- (void)bind:(Generics *)generics type:(GenericsCellType)cellType;
-(void)setEditor:(BOOL)editor;

@end
