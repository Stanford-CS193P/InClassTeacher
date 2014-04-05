//
//  ICNewQuestionViewController.m
//  InClassTeacher
//
//  Created by Johan Ismael on 3/31/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "ICNewQuestionViewController.h"
#import "MultipleChoiceQuestion.h"
#import "TrueFalseQuestion.h"
#import "ICQuestionListViewController.h"

@interface ICNewQuestionViewController ()

@property (weak, nonatomic) IBOutlet UIView *multipleChoicesView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *questionTypeControl;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *questionTextField;
@property (weak, nonatomic) IBOutlet UITextField *choiceTextField1;
@property (weak, nonatomic) IBOutlet UITextField *choiceTextField2;
@property (weak, nonatomic) IBOutlet UITextField *choiceTextField3;
@property (weak, nonatomic) IBOutlet UITextField *choiceTextField4;

@end

@implementation ICNewQuestionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)questionTypeChanged:(UISegmentedControl *)sender {
    self.multipleChoicesView.hidden = (sender.selectedSegmentIndex == 0);
}

- (IBAction)didTapCancelButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)addChoiceFromTextField:(UITextField *)textField
                    toQuestion:(MultipleChoiceQuestion *)question
{
    if ([textField.text length] > 0)
        [question addChoice:textField.text];
}

- (Question *)savedQuestion
{
    Question *newQuestion;
    if (self.questionTypeControl.selectedSegmentIndex == 0) {
        newQuestion = [[TrueFalseQuestion alloc] initWithTitle:self.titleTextField.text
                                                          text:self.questionTextField.text];
    } else {
        newQuestion = [[MultipleChoiceQuestion alloc] initWithTitle:self.titleTextField.text
                                                               text:self.questionTextField.text];
        MultipleChoiceQuestion *question = (MultipleChoiceQuestion *)newQuestion;
        [self addChoiceFromTextField:self.choiceTextField1 toQuestion:question];
        [self addChoiceFromTextField:self.choiceTextField2 toQuestion:question];
        [self addChoiceFromTextField:self.choiceTextField3 toQuestion:question];
        [self addChoiceFromTextField:self.choiceTextField4 toQuestion:question];
    }
    return newQuestion;
}

@end
