//
//  ICQuestionViewController.m
//  InClassTeacher
//
//  Created by Johan Ismael on 4/1/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "ICQuestionViewController.h"
#import "TrueFalseQuestion.h"
#import "MultipleChoiceQuestion.h"

@interface ICQuestionViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIView *multipleChoiceView;
@property (weak, nonatomic) IBOutlet UIView *trueFalseView;
@property (weak, nonatomic) IBOutlet UILabel *choice1Label;
@property (weak, nonatomic) IBOutlet UILabel *choice2Label;
@property (weak, nonatomic) IBOutlet UILabel *choice3Label;
@property (weak, nonatomic) IBOutlet UILabel *choice4Label;

@end

@implementation ICQuestionViewController

- (void)setChoice1Label:(UILabel *)choice1Label
{
    _choice1Label = choice1Label;
    [self setupLabel:choice1Label
             atIndex:1];
}

- (void)setChoice2Label:(UILabel *)choice2Label
{
    _choice2Label = choice2Label;
    [self setupLabel:choice2Label
             atIndex:2];
}

- (void)setChoice3Label:(UILabel *)choice3Label
{
    _choice3Label = choice3Label;
    [self setupLabel:choice3Label
             atIndex:3];
}

- (void)setChoice4Label:(UILabel *)choice4Label
{
    _choice1Label = choice4Label;
    [self setupLabel:choice4Label
             atIndex:4];
}

- (void)setupLabel:(UILabel *)label
           atIndex:(NSUInteger)choicePosition
{
    label.text = @"";
    if (self.question.type == MULTIPLE_CHOICE) {
        MultipleChoiceQuestion *mcp = (MultipleChoiceQuestion *)self.question;
        NSString *choiceText = [mcp choiceAtIndex:choicePosition -1];
        if (choiceText)
            label.text = choiceText;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    self.titleLabel.text = self.question.title;
    self.questionLabel.text = self.question.text;
    self.multipleChoiceView.hidden = (self.question.type == TRUE_FALSE);
    self.trueFalseView.hidden = !self.multipleChoiceView.hidden;
    
    //load answers from server
    //subscribe to notifications
}

@end
