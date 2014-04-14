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

//To override by subclasses
- (NSString *)userDefaultsKey;
- (NSString *)serverEventName;
- (void)setupCell:(UITableViewCell *)cell
      atIndexPath:(NSIndexPath *)path;
- (UITableViewCellStyle)tableViewCellStyle;
- (NSString *)cellIdentifier;
- (id)dataObjectFromDictionary:(NSDictionary *)dictionary;
- (void)setupViewController:(UIViewController *)vc
                atIndexPath:(NSIndexPath *)path;
- (NSString *)segueIdentifier;

@end
