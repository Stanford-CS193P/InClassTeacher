//
//  SlideInTableViewCell.h
//  InClassTeacher
//
//  Created by Johan Ismael on 4/3/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideInTableViewCell : UITableViewCell

@property (nonatomic, copy) void (^confirmationBlock)(void);
@property (assign, nonatomic) BOOL confirmed;

@end
