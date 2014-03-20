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
#import "ICMultipeerManager.h"
#import "TaggedTimestampedDouble.h"

@interface ICTeacherDashboardViewController ()

@property (strong, nonatomic) UIPopoverController *urlPopover;
@property (weak, nonatomic) IBOutlet LiveGraphView *generalLiveGraphView;
@property (weak, nonatomic) IBOutlet LiveGraphView *topicLiveGraphView;
@property (strong, nonatomic) ICMultipeerManager *peerManager;

@end

@implementation ICTeacherDashboardViewController

- (ICMultipeerManager *)peerManager
{
    if (!_peerManager)
        _peerManager = [ICMultipeerManager sharedManager];
    return _peerManager;
}

- (void)setTopicLiveGraphView:(LiveGraphView *)liveGraphView
{
    _topicLiveGraphView = liveGraphView;
    _topicLiveGraphView.bars = 5; //should not be a constant
    _topicLiveGraphView.maxAge = 0.0;
    _topicLiveGraphView.updateInterval = 1.0;
    _topicLiveGraphView.minValue = 0.0;
    _topicLiveGraphView.maxValue = 5.0;    
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveGeneralData:)
                                                 name:kGeneralDataReceivedFromPeerNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTopicData:)
                                                 name:kTopicDataReceivedFromPeerNotification
                                               object:nil];
}

- (void)didReceiveGeneralData:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo] valueForKey:kDataKey];
    TimestampedDouble *timedValue = [[TaggedTimestampedDouble alloc] initWithCreationDate:dict[@"time"]
                                                                                   Double:[dict[@"rating"] doubleValue]];
    [self.generalLiveGraphView addValue:timedValue];
}

- (void)didReceiveTopicData:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo] valueForKey:kDataKey];
    TaggedTimestampedDouble *taggedTimeValue = [[TaggedTimestampedDouble alloc] initWithCreationDate:dict[@"time"]
                                                                                              Double:[dict[@"rating"] doubleValue]
                                                                                                 Tag:dict[@"text"]];
    [self.topicLiveGraphView addValue:taggedTimeValue];
}

@end
