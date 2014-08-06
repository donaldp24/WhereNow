//
//  GenericsTableViewCell.m
//  WhereNow
//
//  Created by Xiaoxue Han on 31/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "GenericsTableViewCell.h"
#import "UIManager.h"
#import "Config.h"

@interface GenericsTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UILabel *lblNumberOfNearby;
@property (nonatomic, weak) IBOutlet UILabel *lblNotes;
@property (nonatomic, weak) IBOutlet UIImageView *ivStatus;

@property (nonatomic, weak) IBOutlet UIView *shadowView;
@property (nonatomic, weak) IBOutlet UIView *actionView;

@end

@implementation GenericsTableViewCell

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
    if (selected)
        self.shadowView.backgroundColor = [UIManager cellHighlightColor];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted)
        self.shadowView.backgroundColor = [UIManager cellHighlightColor];
}

- (void)bind:(Generics *)generics type:(GenericsCellType)cellType
{
    self.generics = generics;
    
    self.cellType = cellType;
    
    self.lblName.text = generics.name;
#if !USE_COREDATA
    self.lblNumberOfNearby.text = [NSString stringWithFormat:@"%d nearby", generics.numberOfNearby];
#else
    self.lblNumberOfNearby.text = [NSString stringWithFormat:@"%d nearby", [generics.numberOfNearby integerValue]];
#endif
    self.lblNotes.text = generics.notes;
    
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

-(void)setEditor:(BOOL)editor animate:(BOOL)animate
{
    if (editor == _editor)
        return;
    
    _editor = editor;
    
#if !USE_SHIFT_ANIMATION_FOR_EDITING_CELL
    void (^updateConstraintsForEditing)(void) = ^void {
        __block CGFloat width = self.frame.size.width;
        if (self.editor) {
            width = 170;
        }
        CGRect frame = self.shadowView.frame;
        frame = CGRectMake(frame.origin.x, frame.origin.y, width, frame.size.height);
        self.shadowView.frame = frame;
        
        [self layoutIfNeeded];
    };
#else
    void (^updateConstraintsForEditing)(void) = ^void {
        __block CGFloat offset = 0;
        if (self.editor) {
            offset = -150;
        }
        CGRect frame = self.shadowView.frame;
        frame = CGRectMake(offset, frame.origin.y, frame.size.width, frame.size.height);
        self.shadowView.frame = frame;
        
        CGRect frameAction = self.actionView.frame;
        frameAction = CGRectMake(frame.size.width + offset, frameAction.origin.y, frameAction.size.width, frameAction.size.height);
        self.actionView.frame = frameAction;
        
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
    //
}

- (IBAction)onLocate:(id)sender
{
    //
}

- (IBAction)onDelete:(id)sender
{
    //
}

@end
