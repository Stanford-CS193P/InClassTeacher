//
//  ICViewController.h
//  InClassTeacher
//
//  Created by Johan Ismael on 2/26/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"

@interface ICSendableDataListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MCSwipeTableViewCellDelegate>

@property (strong, nonatomic) NSMutableArray *data;

//To be used by subclasses
- (void)addElement:(id)element;

//To override
- (NSString *)userDefaultsKey;
- (NSString *)serverEventName;
- (void)setupCell:(UITableViewCell *)cell
            atRow:(NSUInteger)row;
- (UIViewController *)detailViewControllerForRow:(NSUInteger)row;
- (UITableViewCellStyle)tableViewCellStyle;
- (NSString *)cellIdentifier;
- (id)dataObjectFromDictionary:(NSDictionary *)dictionary;

@end
