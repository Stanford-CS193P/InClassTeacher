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
@property (weak, nonatomic) IBOutlet UITableView *wordTableView;
@property (strong, nonatomic) NSMutableArray *words; //of strings
@property (weak, nonatomic) IBOutlet UITextField *wordTextField;

@end

@implementation ICViewController

- (NSMutableArray *)words
{
    if (!_words) _words = [[NSMutableArray alloc] init];
    return _words;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.peerManager = [ICMultipeerManager sharedManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveData:) name:kDataReceivedFromPeerNotification object:nil];
}

- (void)didReceiveData:(NSNotification *)notification
{
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

#pragma mark - IBActions

- (IBAction)didTapAddWordButton:(UIButton *)sender {
    [self.words addObject:self.wordTextField.text];
    [self.wordTableView reloadData];
    self.wordTextField.text = @"";
}

#pragma mark - Table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.words count];
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
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        // Setting the background color of the cell.
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        cell.delegate = self;
    }
    
    UIView *checkView = [self viewWithImageName:@"check"];
    UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
    
    [cell.textLabel setText:self.words[indexPath.row]];
    
    [cell setSwipeGestureWithView:checkView
                            color:greenColor
                             mode:MCSwipeTableViewCellModeExit
                            state:MCSwipeTableViewCellState2
                  completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                      NSIndexPath *indexPath = [self.wordTableView indexPathForCell:cell];
                      
                      //Send data to peers
                      NSData* data = [self.words[indexPath.row]
                                      dataUsingEncoding:NSUTF8StringEncoding];
                      [self.peerManager sendData:data];
                      
                      //remove from table view
                      [self.words removeObjectAtIndex:indexPath.row];
                      [self.wordTableView reloadData];
    }];
    
    return cell;
}

- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell
{
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    textField.text = @"";
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Privates

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

@end
