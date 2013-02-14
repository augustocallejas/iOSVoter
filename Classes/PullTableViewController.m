//
//  PullTableViewController.m
//  Supervote
//
//  Created by augusto callejas on 8/19/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "PullTableViewController.h"

#import "SupervoteAppDelegate.h"

@implementation PullTableViewController

@synthesize pullTableView;

# pragma mark -
# pragma mark PullTableViewDelegate methods

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:0.0f];
}

- (void) refreshTable
{
	SupervoteAppDelegate *appDelegate = (SupervoteAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate updateData:YES];
	
    self.pullTableView.pullLastRefreshDate = appDelegate.lastRefreshDate;
    self.pullTableView.pullTableIsRefreshing = NO;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	self.pullTableView.pullArrowImage = [UIImage imageNamed:@"blackArrow"];
    self.pullTableView.pullBackgroundColor = [UIColor lightTextColor];
    self.pullTableView.pullTextColor = [UIColor blackColor];
	
	SupervoteAppDelegate *appDelegate = (SupervoteAppDelegate *) [[UIApplication sharedApplication] delegate];
	self.pullTableView.pullLastRefreshDate = appDelegate.lastRefreshDate;
	
	[[NSNotificationCenter defaultCenter] addObserver:self.tableView
                                             selector:@selector(reloadData)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
	[super viewDidUnload];
}


- (void)dealloc {
	self.pullTableView = nil;
    [super dealloc];
}


@end

