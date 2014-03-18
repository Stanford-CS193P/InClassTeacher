//
//  ICTeacherDashboardViewController.m
//  InClassTeacher
//
//  Created by Johan Ismael on 3/17/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "ICTeacherDashboardViewController.h"
#import "ICTopicListViewController.h"
#import "LiveGraphView.h"

@interface ICTeacherDashboardViewController ()

@property (strong, nonatomic) UIPopoverController *urlPopover;
@property (weak, nonatomic) IBOutlet LiveGraphView *generalLiveGraphView;
@property (weak, nonatomic) IBOutlet LiveGraphView *topicLiveGraphView;

@end

@implementation ICTeacherDashboardViewController

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"Show Topic List"]) {
        return (!self.urlPopover.popoverVisible) ? YES : NO;
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Topic List"]) {
        if ([segue.destinationViewController isKindOfClass:[ICTopicListViewController class]]) {
            if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
                self.urlPopover = ((UIStoryboardPopoverSegue *)segue).popoverController;
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

@end
