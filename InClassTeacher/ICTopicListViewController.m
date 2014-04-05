//
//  ICTopicListViewController.m
//  InClassTeacher
//
//  Created by Johan Ismael on 3/31/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "ICTopicListViewController.h"
#import "ICTeacherDashboardViewController.h"
#import "TaggedTimestampedDouble.h"

@interface ICTopicListViewController ()

@property (weak, nonatomic) IBOutlet UITextField *wordTextField;

@end

@implementation ICTopicListViewController

#define TOPICS_USER_DEFAULT @"ICTopicListViewController_topics"

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSString *)userDefaultsKey
{
    return TOPICS_USER_DEFAULT;
}

- (void)setupCell:(UITableViewCell *)cell
            atRow:(NSUInteger)row
{
    TaggedTimestampedDouble *ttd = self.data[row];
    cell.textLabel.text = ttd.tag;
}

- (NSString *)serverEventName
{
    return @"CreateConcept";
}

- (id)dataObjectFromDictionary:(NSDictionary *)dictionary
{
    return [TaggedTimestampedDouble taggedTimestampedDoubleFromDictionary:dictionary];
}

#pragma mark - Table View

//change key from conceptName to tag

- (NSString *)cellIdentifier
{
    return @"Topic Cell";
}

- (UIViewController *)detailViewControllerForRow:(NSUInteger)row
{
    return [[ICTeacherDashboardViewController alloc] init];
}

- (UITableViewCellStyle)tableViewCellStyle
{
    return UITableViewCellStyleDefault;
}

#pragma mark - IBActions

- (IBAction)didTapAddWordButton:(UIButton *)sender {
    [self addElementWithTag:self.wordTextField.text];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text length] > 0) {
        [self addElementWithTag:textField.text];
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)addElementWithTag:(NSString *)tag
{
    TaggedTimestampedDouble *ttd = [[TaggedTimestampedDouble alloc] initWithTag:tag];
    [self addElement:ttd];
}

@end
