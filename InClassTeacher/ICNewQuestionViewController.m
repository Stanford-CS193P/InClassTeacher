//
//  ICNewQuestionViewController.m
//  InClassTeacher
//
//  Created by Johan Ismael on 3/31/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "ICNewQuestionViewController.h"

@interface ICNewQuestionViewController ()

@property (weak, nonatomic) IBOutlet UIView *multipleChoicesView;

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

- (IBAction)didTapSaveButton:(UIButton *)sender {
}

@end
