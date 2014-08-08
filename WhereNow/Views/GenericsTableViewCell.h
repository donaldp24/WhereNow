//
//  GenericsTableViewCell.h
//  WhereNow
//
//  Created by Xiaoxue Han on 31/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Generic.h"

typedef enum {
    GenericsCellTypeSearch = 0,
    GenericsCellTypeFavorites
} GenericsCellType;

@protocol GenericsTableViewCellDelegate <NSObject>

@optional
- (void)onGenericDelete:(Generic *)generic;
- (void)onGenericFavorite:(Generic *)generic;
- (void)onGenericLocate:(Generic *)generic;

@end

@interface GenericsTableViewCell : UITableViewCell

@property (nonatomic, retain) Generic *generic;
@property (assign, nonatomic) BOOL editor;
@property (nonatomic) GenericsCellType cellType;

@property (nonatomic, retain) id<GenericsTableViewCellDelegate> delegate;

- (void)bind:(Generic *)generic type:(GenericsCellType)cellType;
-(void)setEditor:(BOOL)editor;
-(void)setEditor:(BOOL)editor animate:(BOOL)animate;

@end
