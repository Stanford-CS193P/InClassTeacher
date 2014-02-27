//
//  ICViewController.m
//  InClassTeacher
//
//  Created by Johan Ismael on 2/26/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "ICViewController.h"
#import "ICMultipeerManager.h"

@interface ICViewController ()

@property (strong, nonatomic) ICMultipeerManager *peerManager;

@end

@implementation ICViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.peerManager = [[ICMultipeerManager alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveData:) name:kDataReceivedFromPeerNotification object:nil];
}

- (void)didReceiveData:(NSNotification *)notification
{
    NSLog(@"==============> %@", @"got notif");
    NSData *data = [[notification userInfo] valueForKey:kDataKey];
    NSString *dataStr =
    [[NSString alloc] initWithData:data
                          encoding:NSUTF8StringEncoding];
    NSArray *values = [dataStr componentsSeparatedByString:@","];
    
    dispatch_async(dispatch_get_main_queue(), ^{
                       self.view.backgroundColor = [UIColor colorWithRed:[values[0] floatValue]
                                                                   green:[values[1] floatValue]
                                                                    blue:[values[2] floatValue]
                                                                   alpha:1.0];
                   });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
