//
//  ICTeacherDashboardViewController.m
//  InClassTeacher
//
//  Created by Johan Ismael on 3/17/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "ICTeacherDashboardViewController.h"
#import "ICSendableDataListViewController.h"
#import "LiveGraphView.h"
#import "ICSRemoteClient.h"
#import "TaggedTimestampedDouble.h"

@interface ICTeacherDashboardViewController ()

@property (strong, nonatomic) UIPopoverController *urlPopover;
@property (weak, nonatomic) IBOutlet LiveGraphView *generalLiveGraphView;
@property (strong, nonatomic) ICSRemoteClient *peerManager;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation ICTeacherDashboardViewController

- (ICSRemoteClient *)peerManager
{
    if (!_peerManager)
        _peerManager = [ICSRemoteClient sharedManager];
    return _peerManager;
}

- (void)setGeneralLiveGraphView:(LiveGraphView *)generalLiveGraphView
{
    _generalLiveGraphView = generalLiveGraphView;
    _generalLiveGraphView.bars = 5;
    _generalLiveGraphView.maxAge = 0;
    _generalLiveGraphView.updateInterval = 1.0;
    _generalLiveGraphView.minValue = -1;
    _generalLiveGraphView.maxValue = 5;
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
        if ([segue.destinationViewController isKindOfClass:[ICSendableDataListViewController class]]) {
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSendTopic:)
                                                 name:kRawDataSentToPeers
                                               object:nil];
}

- (void)didSendTopic:(NSNotification *)notification
{
    NSDictionary *data = notification.userInfo[kRawDataSentToPeersDataKey];
    NSString *tag = [data objectForKey:@"conceptName"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.generalLiveGraphView tag:tag];
    });
}

- (void)didReceiveGeneralData:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo] valueForKey:kDataKey];
    TimestampedDouble *timedValue = [[TaggedTimestampedDouble alloc] initWithCreationDate:dict[@"time"]
                                                                                   Double:[dict[@"rating"] doubleValue]];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.generalLiveGraphView[dict[@"peerIDDisplayName"]] = timedValue;
    });
}

- (void)didReceiveTopicData:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo] valueForKey:kDataKey];
    TaggedTimestampedDouble *taggedTimeValue = [[TaggedTimestampedDouble alloc] initWithCreationDate:dict[@"time"]
                                                                                              Double:[dict[@"rating"] doubleValue]
                                                                                                 Tag:dict[@"text"]];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.generalLiveGraphView[dict[@"peerIDDisplayName"]] = taggedTimeValue;
    });
}

@end
