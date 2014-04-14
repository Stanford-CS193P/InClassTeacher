//
//  ICViewController.m
//  InClassTeacher
//
//  Created by Johan Ismael on 2/26/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "ICSendableDataListViewController.h"
#import "ICSRemoteClient.h"
#import "ICTeacherDashboardViewController.h"
#import "SlideInTableViewCell.h"
#import "SendableData.h"

@interface ICSendableDataListViewController () <UISplitViewControllerDelegate>

@property (strong, nonatomic) ICSRemoteClient *peerManager;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@end

@implementation ICSendableDataListViewController

#pragma mark - Lazy instantiation

- (NSMutableArray *)data
{
    if (!_data) _data = [[NSMutableArray alloc] init];
    return _data;
}

#pragma mark - View Controller lifecycle

- (void)awakeFromNib
{
    if (!self.splitViewController.delegate)
        self.splitViewController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.peerManager = [ICSRemoteClient sharedManager];
    
    NSArray *plistData = [[[NSUserDefaults standardUserDefaults] arrayForKey:[self userDefaultsKey]] mutableCopy];
    for (NSDictionary *dic in plistData) {
        [self.data addObject:[self dataObjectFromDictionary:dic]];
    }
    [self.dataTableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *path = [self.dataTableView indexPathForCell:cell];
        [self setupViewController:segue.destinationViewController
                      atIndexPath:path];
    }
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    //need to implement to enable swipe gesture to bring master view
}

#pragma mark - Table view datasource and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellIdentifier];
    
    SlideInTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[SlideInTableViewCell alloc] initWithStyle:[self tableViewCellStyle]
                                           reuseIdentifier:cellIdentifier];
    }
    
    id<SendableData> data = self.data[indexPath.row];
    __weak SlideInTableViewCell *weakCell = cell;
    [cell setConfirmationBlock:^{
        [self.peerManager sendEvent:[self serverEventName]
                           withData:[data toDictionary]
                           callback:^(id response) {
                               data.objectId = response[kObjectIdKey];
                               [self persistData];
                               if ([self segueIdentifier]) {
                                   [self performSegueWithIdentifier:[self segueIdentifier]
                                                             sender:weakCell];
                               }
                           }];
        data.sent = YES;
        [self persistData];
        [self.dataTableView reloadData];
    }];
    
    [self setupCell:cell
        atIndexPath:indexPath];
    cell.confirmed = data.sent;
    
    return cell;
}

- (void)addElement:(id)element
{
    [self.data addObject:element];
    [self persistData];
    [self.dataTableView reloadData];
}

//This is a sledgehammer approach (replacing the whole array even for a single field) but should be fine for now
- (void)persistData
{
    NSMutableArray *plistData = [[NSMutableArray alloc] init];
    for (id<SendableData> data in self.data) {
        [plistData addObject:[data toDictionary]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:plistData
                                              forKey:[self userDefaultsKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Subclasses

- (NSString *)segueIdentifier
{
    return nil;
}

- (void)setupViewController:(UIViewController *)vc
                atIndexPath:(NSIndexPath *)path
{
    
}

- (id)dataObjectFromDictionary:(NSDictionary *)dictionary
{
    return nil;
}

- (NSString *)userDefaultsKey
{
    return @"";
}

- (void)setupCell:(UITableViewCell *)cell
      atIndexPath:(NSIndexPath *)path
{
    
}

- (NSString *)cellIdentifier
{
    return @"Cell";
}

- (UITableViewCellStyle)tableViewCellStyle
{
    return UITableViewCellStyleDefault;
}

- (NSDictionary *)dataForRow:(NSUInteger)row
{
    return nil;
}

- (NSString *)serverEventName
{
    return @"";
}

- (NSString *)textForCellAtRow:(NSUInteger)row
{
    return @"";
}

@end
