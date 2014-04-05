//
//  SlideInTableViewCell.m
//  InClassTeacher
//
//  Created by Johan Ismael on 4/3/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "SlideInTableViewCell.h"

@interface SlideInTableViewCell()

@property (strong, nonatomic) UIView *upperView;
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
                             self.upperView.frame = CGRectMake(-BUTTON_WIDTH, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
                         } completion:nil];
    }
    
    else {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.upperView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
                         } completion:nil];
    }
}

- (void)setConfirmed:(BOOL)confirmed
{
    _confirmed = confirmed;
    if (confirmed) {
        self.slidedIn = NO;
        [self removeGestureRecognizer:self.tapRecognizer];
        self.tapRecognizer = nil;
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        if (!self.tapRecognizer) {
            self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(tappedCell:)];
            [self addGestureRecognizer:self.tapRecognizer];
        }
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}


// sent has to be stored in NSUserDefaults
// sendable data protocol, create such a type for a topic, question implements it as well



- (void)setupUpperView
{
    self.upperView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    [self.upperView addSubview:self.textLabel];
    [self.upperView addSubview:self.detailTextLabel];
    self.upperView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.upperView];
}

- (void)setupButton
{
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.confirmButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [UIColor greenColor];
    self.confirmButton.frame = CGRectMake(self.contentView.bounds.size.width - BUTTON_WIDTH, 0, BUTTON_WIDTH, self.contentView.bounds.size.height);
    [self.confirmButton addTarget:self
                           action:@selector(confirmButtonTapped)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.confirmButton];
    [self.contentView sendSubviewToBack:self.confirmButton];
}

- (void)setup
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setupButton];
    [self setupUpperView];
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(tappedCell:)];
    [self addGestureRecognizer:self.tapRecognizer];
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

@end
