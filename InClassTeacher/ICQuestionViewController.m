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
#import "ICSRemoteClient.h"
#import "LiveBarChartView.h"

@interface ICQuestionViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIView *multipleChoiceView;
@property (weak, nonatomic) IBOutlet UIView *trueFalseView;
@property (weak, nonatomic) IBOutlet UILabel *choice1Label;
@property (weak, nonatomic) IBOutlet UILabel *choice2Label;
@property (weak, nonatomic) IBOutlet UILabel *choice3Label;
@property (weak, nonatomic) IBOutlet UILabel *choice4Label;
@property (strong, nonatomic) ICSRemoteClient *remoteClient;
@property (weak, nonatomic) IBOutlet LiveBarChartView *barChartView;

@end

@implementation ICQuestionViewController

- (ICSRemoteClient *)remoteClient
{
    if (!_remoteClient)
        _remoteClient = [ICSRemoteClient sharedManager];
    return _remoteClient;
}

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
    
//    NSArray *choices = @[@"now", @"here", @"sometimes", @"before"];
//    MultipleChoiceQuestion *testQ = [[MultipleChoiceQuestion alloc] initWithTitle:@"Test" text:@"what's my test?"];
//    [testQ addChoice:choices[0]];
//    [testQ addChoice:choices[1]];
//    [testQ addChoice:choices[2]];
//    [testQ addChoice:choices[3]];
//    self.question = testQ;
//    self.question.objectId = @"TEST";
//    
    [self setupBarView];
//    
//    for (NSUInteger i = 0; i < 50; i++) {
//        [self.barChartView addDataPoint:choices[arc4random()%[choices count]]];
//    }
    
    self.titleLabel.text = self.question.title;
    self.questionLabel.text = self.question.text;
    self.multipleChoiceView.hidden = (self.question.type == TRUE_FALSE);
    self.trueFalseView.hidden = !self.multipleChoiceView.hidden;
    
    //load answers from server
    [self.remoteClient sendEvent:@"GetResponsesForQuestionId"
                        withData:@{@"questionID": self.question.objectId}
                        callback:^(id response) {
                            NSMutableArray *responses = (NSMutableArray *)response;
                            for (NSDictionary *responseDict in responses) {
                                [self.barChartView addDataPoint:responseDict[@"response"]];
                            }
    }];
    
    //subscribe to notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveResponse:)
                                                 name:kQuestionResponseReceived
                                               object:nil];
    
//    [NSTimer scheduledTimerWithTimeInterval:1.0
//                                     target:self
//                                   selector:@selector(newResponse:)
//                                   userInfo:nil
//                                    repeats:YES];
}

- (void)newResponse:(NSTimer *)timer
{
    NSArray *choices = @[@"now", @"here", @"sometimes", @"before"];
    [self.barChartView addDataPoint:choices[arc4random()%[choices count]]];
}

- (void)setupBarView
{
    if (self.question.type == TRUE_FALSE) {
        self.barChartView.categories = @[@"True", @"False"];
    } else {
        MultipleChoiceQuestion *q = (MultipleChoiceQuestion *)self.question;
        self.barChartView.categories = q.choicesArray;
    }
}

- (void)didReceiveResponse:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo] valueForKey:kDataKey];
    
    if ([dict[@"questionID"] isEqualToString:self.question.objectId]) {
        [self.barChartView addDataPoint:dict[@"response"]];
    }
}


@end
