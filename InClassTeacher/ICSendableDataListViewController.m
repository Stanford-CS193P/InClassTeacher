//
//  ICViewController.m
//  InClassTeacher
//
//  Created by Johan Ismael on 2/26/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "ICTopicListViewController.h"
#import "ICSRemoteClient.h"
#import "ICTeacherDashboardViewController.h"

@interface ICTopicListViewController () <UISplitViewControllerDelegate>

@property (strong, nonatomic) ICSRemoteClient *peerManager;
@property (weak, nonatomic) IBOutlet UITableView *wordTableView;
@property (strong, nonatomic) NSMutableArray *words; //of strings
@property (weak, nonatomic) IBOutlet UITextField *wordTextField;

@end

@implementation ICTopicListViewController

#define WORDS_USER_DEFAULT @"ICTopicListViewController_words"

- (NSMutableArray *)words
{
    if (!_words) _words = [[NSMutableArray alloc] init];
    return _words;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.peerManager = [ICSRemoteClient sharedManager];
    
    self.words = [[[NSUserDefaults standardUserDefaults] arrayForKey:WORDS_USER_DEFAULT] mutableCopy];
    if ([self.words count]) {
        [self.wordTableView reloadData];
    } else {
        [self addWord:@"TESTING"];
    }
}

#pragma mark - UISplitViewControllerDelegate

- (void)awakeFromNib
{
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
    barButtonItem.title = @"Topic List";
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

#pragma mark - IBActions

- (IBAction)didTapAddWordButton:(UIButton *)sender {
    [self addWord:self.wordTextField.text];
}

#pragma mark - Table view datasource and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.words count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"==============> %@", @"select");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // Remove inset of iOS 7 separators.
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        
        // Setting the background color of the cell.
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        cell.delegate = self;
    }
    
    UIView *checkView = [self viewWithImageName:@"check"];
    UIColor *greenColor = [UIColor colorWithRed:134.0 / 255.0
                                          green:191.0 / 255.0
                                           blue:60.0 / 255.0
                                          alpha:1.0];
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Avenir Next" size:20.0]];
    [cell.textLabel setText:self.words[indexPath.row]];
    
    [cell setSwipeGestureWithView:checkView
                            color:greenColor
                             mode:MCSwipeTableViewCellModeSwitch
                            state:MCSwipeTableViewCellState2
                  completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                      NSIndexPath *indexPath = [self.wordTableView indexPathForCell:cell];
                      
                      //Send data to peers
                      [self.peerManager sendEvent:@"CreateConcept" withData:@{@"conceptName": self.words[indexPath.row]}];
                      
                      //remove from table view
                      cell.contentView.backgroundColor = greenColor;
//                      [self.words removeObjectAtIndex:indexPath.row];
//                      [self.wordTableView reloadData];
                      
    }];
    
    return cell;
}


- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell
{
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text length] > 0) {
        [self addWord:textField.text];
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Privates

- (void)addWord:(NSString *)word
{
    [self.words addObject:word];
    [[NSUserDefaults standardUserDefaults] setObject:self.words forKey:WORDS_USER_DEFAULT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.wordTableView reloadData];
    self.wordTextField.text = @"";
}

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

@end
