//
//  ICQuestionViewController.m
//  InClassTeacher
//
//  Created by Johan Ismael on 3/31/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "ICQuestionListViewController.h"
#import "Question.h"
#import "ICNewQuestionViewController.h"
#import "ICQuestionViewController.h"
#import "QuestionFactory.h"

@interface ICQuestionListViewController ()

@property (strong, nonatomic) NSMutableArray *questionData; //of Questions

@end

@implementation ICQuestionListViewController

#define QUESTIONS_USER_DEFAULTS @"ICQuestionListViewController_questions"

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSString *)userDefaultsKey
{
    return QUESTIONS_USER_DEFAULTS;
}

- (NSString *)serverEventName
{
    return @"CreateQuestion";
}

- (id)dataObjectFromDictionary:(NSDictionary *)dictionary
{
    return [QuestionFactory questionFromDictionary:dictionary];
}

#pragma mark - Table View

- (void)setupCell:(UITableViewCell *)cell
            atRow:(NSUInteger)row
{
    Question *question = self.data[row];
    cell.textLabel.text = question.title;
    cell.detailTextLabel.text = question.text;
}

- (UIViewController *)detailViewControllerForRow:(NSUInteger)row
{
    return nil;
}

- (NSString *)cellIdentifier
{
    return @"Question Cell";
}

- (UITableViewCellStyle)tableViewCellStyle
{
    return UITableViewCellStyleSubtitle;
}

#pragma mark - IBActions

- (IBAction)didSaveQuestion:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[ICNewQuestionViewController class]]) {
        ICNewQuestionViewController *nqvc = (ICNewQuestionViewController *)segue.sourceViewController;
        Question *newQuestion = [nqvc savedQuestion];
        [self addElement:newQuestion];
    }
}

@end
