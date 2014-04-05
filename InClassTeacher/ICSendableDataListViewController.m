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

- (NSMutableArray *)data
{
    if (!_data) _data = [[NSMutableArray alloc] init];
    return _data;
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

- (id)dataObjectFromDictionary:(NSDictionary *)dictionary
{
    return nil;
}

- (NSString *)userDefaultsKey
{
    return @"";
}

//[self.peerManager sendEvent:@"CreateConcept" withData:@{@"conceptName": self.words[indexPath.row]}];

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    
}

#pragma mark - UISplitViewControllerDelegate

- (void)awakeFromNib
{
    if (!self.splitViewController.delegate)
        self.splitViewController.delegate = self;
}

// Returns the detail view of the split view controller,
// as long as it has a `splitViewBarButtonItem` property.
- (id)splitViewDetailWithBarButtonItem
{
    id detail = [self.splitViewController.viewControllers lastObject];
    if (![detail respondsToSelector:@selector(setSplitViewBarButtonItem:)] ||
        ![detail respondsToSelector:@selector(splitViewBarButtonItem)]) detail = nil;
    return detail;
}

// When the master view controller is to be hidden, add the given `UIBarButtonItem` to the
// current detail view.
- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Menu";
    id detailViewController = [self splitViewDetailWithBarButtonItem];
    [detailViewController setSplitViewBarButtonItem:barButtonItem];
}

// When the master view controller is to be shown, remove any split view bar button item
// from the current detail view because it is now invalid.
- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    id detailViewController = [self splitViewDetailWithBarButtonItem];
    [detailViewController setSplitViewBarButtonItem:nil];
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
    [cell setConfirmationBlock:^{
        [self.peerManager sendEvent:[self serverEventName]
                           withData:[data toDictionary]];
        data.sent = YES;
        [self persistData];
        [self.dataTableView reloadData];
    }];
    
    
    [self setupCell:cell
              atRow:indexPath.row];
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

- (void)setupCell:(UITableViewCell *)cell
            atRow:(NSUInteger)row
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
