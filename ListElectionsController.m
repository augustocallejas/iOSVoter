//
//  ListElectionsController.m
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "ListElectionsController.h"

#import "YRDropdownView.h"

#import "Candidate.h"
#import "DisplayBallotController.h"
#import "Election.h"
#import "Measure.h"
#import "Position.h"
#import "SupervoteAppDelegate.h"

static NSString *hintName = @"ListElectionsHint";

/* remove these when we're ready to support 4.2 */
/* http://useyourloaf.com/blog/2010/11/27/iad-framework-updates-for-ios-42.html */
NSString *kTabnavADBannerContentSizeIdentifierPortrait;
NSString *kTabnavADBannerContentSizeIdentifierLandscape;

@implementation ListElectionsController

@synthesize tableView;
@synthesize bannerView;
@synthesize selectedElection;
@synthesize client = _client;
@synthesize facebookClient = _facebookClient;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController1 = _fetchedResultsController1;
@synthesize fetchedResultsController2 = _fetchedResultsController2;

#pragma mark -
#pragma mark ADBannerViewDelegate methods

- (void)moveBannerViewOffscreen {
	LogDebug(@"Moving Ad Banner offscreen");
	// Make the table biew take up the void left by the banner
	CGRect originalTableFrame = self.tableView.frame;
	CGFloat newTableHeight = self.view.frame.size.height;
	CGRect newTableFrame = originalTableFrame;
	newTableFrame.size.height = newTableHeight;
	
	// Position the banner below the table view (offscreen).
	CGRect newBannerFrame = self.bannerView.frame;
	newBannerFrame.origin.y = newTableHeight;
	
	self.tableView.frame = newTableFrame;
	self.bannerView.frame = newBannerFrame;	
}

- (void)moveBannerViewOnscreen {
	LogDebug(@"Moving Ad Banner onscreen");
	CGRect newBannerFrame = self.bannerView.frame;
	newBannerFrame.origin.y = self.view.frame.size.height - newBannerFrame.size.height;
	
	CGRect originalTableFrame = self.tableView.frame;
	CGFloat newTableHeight = self.view.frame.size.height - newBannerFrame.size.height;
	CGRect newTableFrame = originalTableFrame;
	newTableFrame.size.height = newTableHeight;
	
	[UIView beginAnimations:@"BannerViewIntro" context:nil];
	self.tableView.frame = newTableFrame;
	self.bannerView.frame = newBannerFrame;
	[UIView commitAnimations];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	LogDebug(@"Ad Banner failed to receive Ad: %@", [error localizedDescription]);
	[self moveBannerViewOffscreen];
}


- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
	// pause animations
	LogDebug(@"bannerViewActionShouldBegin");
	return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
	// start animations
	LogDebug(@"bannerViewActionDidFinish");
}


- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	LogDebug(@"bannerViewDidLoadAd");
	[self moveBannerViewOnscreen];
}


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
	
    self.tableView.pullLastRefreshDate = appDelegate.lastRefreshDate;
    self.tableView.pullTableIsRefreshing = NO;
}

#pragma mark -

- (NSFetchedResultsController *)fetchedResultsController1 {
	/* singleton pattern, lazy instantiation */
    if (_fetchedResultsController1 != nil) {
        return _fetchedResultsController1;
    }
	
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Election" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
    [fetchRequest setFetchBatchSize:20];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"status = 1"]];
	
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								  managedObjectContext:_managedObjectContext
																									sectionNameKeyPath:nil
																											 cacheName:nil];
    self.fetchedResultsController1 = theFetchedResultsController;
	self.fetchedResultsController1.delegate = self;
	
	[sort release];
    [fetchRequest release];
    [theFetchedResultsController release];
	
    return _fetchedResultsController1;    
}

- (NSFetchedResultsController *)fetchedResultsController2 {
	/* singleton pattern, lazy instantiation */
    if (_fetchedResultsController2 != nil) {
        return _fetchedResultsController2;
    }
	
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Election" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
	
    [fetchRequest setFetchBatchSize:20];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"status = 0"]];
	
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								  managedObjectContext:_managedObjectContext
																									sectionNameKeyPath:nil
																											 cacheName:nil];
    self.fetchedResultsController2 = theFetchedResultsController;
	self.fetchedResultsController2.delegate = self;
	
	[sort release];
    [fetchRequest release];
    [theFetchedResultsController release];
	
    return _fetchedResultsController2;    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	//cell.textLabel.font = [UIFont fontWithName:@"OSP-DIN" size:20.0];
	//cell.textLabel.font = [UIFont fontWithName:@"LeagueGothic" size:20.0];
//	cell.textLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14.0];
	cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
//	cell.textLabel.minimumFontSize = 13.0;
//	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	Election *election = nil;
	if (indexPath.section < [self.fetchedResultsController1.sections count]) {
		election = (Election *) [self.fetchedResultsController1 objectAtIndexPath:indexPath];
	}
	else {
		NSIndexPath *correctedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section-[self.fetchedResultsController1.sections count])];
		election = (Election *) [self.fetchedResultsController2 objectAtIndexPath:correctedIndexPath];
	}
	
	cell.imageView.image = nil;
    cell.textLabel.text = election.title;
    cell.detailTextLabel.text =  [dateFormatter stringFromDate:election.date];
//	cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
	
	if (election.icon != nil) {
		UIImage *icon = [UIImage imageNamed:election.icon];
		if (icon != nil) {
			cell.imageView.image = icon;
		}
	}
	
	[cell setNeedsLayout];
}

#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	if (_fetchedResultsController2 == controller) {
		NSInteger count1 = [self.fetchedResultsController1.sections count];
		if (indexPath != nil) {
			indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:count1+indexPath.section];
		}
		if (newIndexPath != nil) {
			newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:count1+newIndexPath.section];
		}
	}
	
    switch(type) {
			
        case NSFetchedResultsChangeInsert:
			LogDebug(@"Inserting at section %d, row %d", newIndexPath.section, newIndexPath.row);
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
			LogDebug(@"Deleting %@", indexPath);
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
			LogDebug(@"Update at section %d, row %d", indexPath.section, indexPath.row);
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
			
        case NSFetchedResultsChangeMove:
			LogDebug(@"Move %@ %@", indexPath, newIndexPath);
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Reloading the section inserts a new row and ensures that titles are updated appropriately.
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
    switch(type) {
			
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.fetchedResultsController1.sections count] + [self.fetchedResultsController2.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo;
	if (section < [self.fetchedResultsController1.sections count]) {
		sectionInfo = [[self.fetchedResultsController1 sections] objectAtIndex:section];
	}
	else {
		sectionInfo = [[self.fetchedResultsController2 sections] objectAtIndex:section-[self.fetchedResultsController1.sections count]];
	}
	
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"ListElectionController";
	    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 32.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	/* http://www.iphonedevsdk.com/forum/iphone-sdk-development/5172-font-size-color-tableview-header.html */
	UIFont *font = [UIFont fontWithName:@"LeagueGothic" size:22.0];
	
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 32.0)] autorelease];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.opaque = NO;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor darkGrayColor];
	label.font = font;
	label.adjustsFontSizeToFitWidth = YES;
	label.minimumFontSize = 18.0;
	label.frame = CGRectMake(10.0, 0.0, 290.0, 32.0);
	
	if (section < [self.fetchedResultsController1.sections count]) {
		label.text = NSLocalizedString(@"UpcomingElections", nil);
	}
	else {
		label.text = NSLocalizedString(@"PastElections", nil);
	}
	
	[customView addSubview:label];
	[label release];
	return customView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DisplayBallotController *controller = [[DisplayBallotController alloc] initWithNibName:@"DisplayBallot" bundle:[NSBundle mainBundle]];
	
	self.selectedElection = indexPath;
	
	Election *election = nil;
	if (indexPath.section < [self.fetchedResultsController1.sections count]) {
		election = (Election *) [self.fetchedResultsController1 objectAtIndexPath:indexPath];
	}
	else {
		NSIndexPath *correctIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section-[self.fetchedResultsController1.sections count])];
		election = (Election *) [self.fetchedResultsController2 objectAtIndexPath:correctIndexPath];
	}

	controller.election = election;
	controller.title = NSLocalizedString(@"Ballot", nil);
	controller.managedObjectContext = self.managedObjectContext;
	controller.client = self.client;
	
	[[self navigationController] pushViewController:controller animated:YES];
	[controller release];
}

#pragma mark -
#pragma mark UIViewController methods

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		
        kTabnavADBannerContentSizeIdentifierPortrait = ADBannerContentSizeIdentifierPortrait;
        kTabnavADBannerContentSizeIdentifierLandscape = ADBannerContentSizeIdentifierLandscape;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	bannerView = [[ADBannerView alloc] initWithFrame: CGRectMake(0, 410, 320, 50)];
	[bannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects: 
													kTabnavADBannerContentSizeIdentifierPortrait, nil]];
    bannerView.currentContentSizeIdentifier = kTabnavADBannerContentSizeIdentifierPortrait;
    bannerView.delegate = self;
	
	[self.view addSubview:bannerView];
	
	[self moveBannerViewOffscreen];
	
	hintDisplayed = [[NSUserDefaults standardUserDefaults] objectForKey:hintName] != nil;
	
	/* http://stackoverflow.com/questions/599405/iphone-navigation-bar-title-text-color */
	UIFont *font = [UIFont fontWithName:@"LeagueGothic" size:30.0];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	label.font = font;
	//label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.text = self.title;
	[label sizeToFit];
	self.navigationItem.titleView = label;
	[label release];
	
	NSError *error = nil;
	if (![[self fetchedResultsController1] performFetch:&error]) {
		// Update to handle the error appropriately.
		LogError(@"Error while performing a fetch: %@", [error localizedDescription]);
	}
	
	if (![[self fetchedResultsController2] performFetch:&error]) {
		// Update to handle the error appropriately.
		LogError(@"Error while performing a fetch: %@", [error localizedDescription]);
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.selectedElection != nil) {
		[self.tableView deselectRowAtIndexPath:self.selectedElection animated:NO];
		self.selectedElection = nil;
	}
	
	if (!hintDisplayed) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:@"1" forKey:hintName];
		[defaults synchronize];
		hintDisplayed = YES;
		
		[YRDropdownView showDropdownInView:self.tableView
									 title:NSLocalizedString(@"WelcomeTitle", nil)
									detail:NSLocalizedString(hintName, nil)
									 image:nil
								  animated:YES
								 hideAfter:8.0f];
	}
}

//- (void)viewWillDisappear:(BOOL)animated {
//	NSLog(@"viewWillDisappear");
//	[self moveBannerViewOffscreen];
//}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}
*/

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[bannerView removeFromSuperview];
	self.bannerView.delegate = nil;
	self.bannerView = nil;
	self.navigationItem.titleView = nil;
	self.fetchedResultsController1.delegate = nil;
	self.fetchedResultsController1 = nil;
	self.fetchedResultsController2.delegate = nil;
	self.fetchedResultsController2 = nil;
	[super viewDidUnload];
}


- (void)dealloc {
	self.tableView = nil;
	self.selectedElection = nil;
	self.client = nil;
	self.facebookClient = nil;
	self.managedObjectContext = nil;
	self.fetchedResultsController1.delegate = nil;
	self.fetchedResultsController1 = nil;
	self.fetchedResultsController2.delegate = nil;
	self.fetchedResultsController2 = nil;
	[dateFormatter release];
    [super dealloc];
}


@end
