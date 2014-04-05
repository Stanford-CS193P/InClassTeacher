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

@property (nonatomic, strong) Question *question;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIView *multipleChoiceView;
@property (weak, nonatomic) IBOutlet UIView *trueFalseView;

@end

@implementation ICQuestionViewController

- (instancetype)initWithQuestionDictionary:(NSDictionary *)questionDictionary
{
    self = [super init];
    if (self) {
        NSString *title = questionDictionary[kTitleKey];
        NSString *text = questionDictionary[kTextKey];
        if ([questionDictionary[kTypeKey] integerValue] == TRUE_FALSE) {
            _question = [[TrueFalseQuestion alloc] initWithTitle:title
                                                            text:text];
        } else {
            _question = [[MultipleChoiceQuestion alloc] initWithTitle:title
                                                                 text:text];
            for (NSString *choice in questionDictionary[kChoicesKey]) {
                [(MultipleChoiceQuestion *)_question addChoice:choice];
            }
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.questionLabel.text = self.question.text;
    self.multipleChoiceView.hidden = (self.question.type == TRUE_FALSE);
    self.trueFalseView.hidden = !self.multipleChoiceView.hidden;
    
    //load answers from server
    //subscribe to notifications
}


@end
