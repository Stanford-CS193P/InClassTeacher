//
//  SlideInTableViewCell.m
//  InClassTeacher
//
//  Created by Johan Ismael on 4/3/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "SlideInTableViewCell.h"

@interface SlideInTableViewCell()

@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (assign, nonatomic) BOOL slidedIn;

@end

@implementation SlideInTableViewCell

#define BUTTON_WIDTH 80

- (void)setSlidedIn:(BOOL)slidedIn
{
    _slidedIn = slidedIn;
    if (slidedIn) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.confirmButton.frame = CGRectMake(self.contentView.bounds.size.width-BUTTON_WIDTH, 0, BUTTON_WIDTH, self.contentView.bounds.size.height);
                         } completion:nil];
    }
    
    else {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.confirmButton.frame = CGRectMake(self.contentView.bounds.size.width, 0, BUTTON_WIDTH, self.contentView.bounds.size.height);
                         } completion:nil];
    }
}

- (UIButton *)confirmButton
{
    if (!_confirmButton) {
        CGFloat cellWidth = self.contentView.bounds.size.width;
        CGFloat cellHeight = self.contentView.bounds.size.height;
        _confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_confirmButton setTitle:@"Send" forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext" size:14];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.backgroundColor = [UIColor greenColor];
        _confirmButton.frame = CGRectMake(cellWidth, 0, BUTTON_WIDTH, cellHeight);
        [_confirmButton addTarget:self
                           action:@selector(confirmButtonTapped)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (void)setConfirmed:(BOOL)confirmed
{
    _confirmed = confirmed;
    if (confirmed) {
        [self toggleSlideTap:NO];
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        [self toggleSlideTap:YES];
    }
}

- (void)addConfirmButton
{
    [self.contentView addSubview:self.confirmButton];
}

- (void)setup
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self addConfirmButton];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self setup];
}

#pragma mark - Tap

- (void)tappedCell:(UIGestureRecognizer *)gesture
{
    if (!self.confirmed)
        self.slidedIn = !self.slidedIn;
}

- (void)confirmButtonTapped
{
    if (self.confirmationBlock)
        self.confirmationBlock();
    self.confirmed = YES;
}

#pragma mark - Table View Cell overrides

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing) {
        [self toggleSlideTap:NO];
    } else {
        if (!self.confirmed) {
            [self toggleSlideTap:YES];
        }
    }
}

- (void)toggleSlideTap:(BOOL)on
{
    if (on) {
        if (!self.tapRecognizer) {
            self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(tappedCell:)];
            [self addGestureRecognizer:self.tapRecognizer];
        }
    } else {
        [self removeGestureRecognizer:self.tapRecognizer];
        self.tapRecognizer = nil;
        [self.confirmButton removeFromSuperview];
    }
}

- (void)didTransitionToState:(UITableViewCellStateMask)state
{
    if (state == UITableViewCellStateDefaultMask)
        [self.contentView addSubview:self.confirmButton];
}

@end
