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
#import "TrueFalseQuestion.h"

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
      atIndexPath:(NSIndexPath *)path
{
    Question *question = self.data[path.row];
    cell.textLabel.text = question.title;
    cell.detailTextLabel.text = question.text;
}

- (UIViewController *)viewControllerForIndexPath:(NSIndexPath *)path
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

- (NSString *)segueIdentifier
{
    return @"ReplaceQuestion";
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

- (void)setupViewController:(UIViewController *)vc
                atIndexPath:(NSIndexPath *)path
{
    if ([vc isKindOfClass:[ICQuestionViewController class]]) {
        ICQuestionViewController *qvc = (ICQuestionViewController *)vc;

//        NSArray *choices = @[@"now", @"here", @"sometimes", @"before"];
        TrueFalseQuestion *testQ = [[TrueFalseQuestion alloc] initWithTitle:@"Test" text:@"what's my test?"];
        testQ.objectId = @"TEST";
        
        qvc.question = testQ;

//        qvc.question = self.data[path.row];
    }
}

@end
