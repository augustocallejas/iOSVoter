//
//  ListElectionsController.m
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "ListElectionsController.h"

#import "Candidate.h"
#import "DisplayBallotController.h"
#import "Election.h"
#import "FacebookFriend.h"
#import "Friend.h"
#import "FriendBallotVote.h"
#import "FriendMeasureVote.h"
#import "Measure.h"
#import "Position.h"

@implementation ListElectionsController

@synthesize client = _client;

#pragma mark -
#pragma mark FetchedResultsBasedTableViewController methods

- (NSString *)getEntityName{
	return @"Election";
}

- (NSString *)getSectionNameKeyPath{
	return nil;
}

- (NSString *)getCacheName{
	return @"ListElectionsController";
}

- (NSArray *)allocSortDescriptors{
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	return [NSArray arrayWithObject:sort];
}

- (NSPredicate *)getPredicate{
	return nil;
}

- (NSString *)getCellIdentifier{
	return @"ListElectionsController";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    Election *election = (Election *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = election.title;
    cell.detailTextLabel.text =  [dateFormatter stringFromDate:election.date];
	
	UIImage *icon = [UIImage imageNamed:@"users.png"];
	cell.imageView.image = icon;
}


#pragma mark -
#pragma mark UITableViewDataSource methods

// Overriding the section name creation
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	if (section == 0)
//	{
//		return @"Elections";
//	}
	
	return nil;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DisplayBallotController *controller = [[DisplayBallotController alloc] initWithNibName:@"DisplayBallot" bundle:[NSBundle mainBundle]];
	
	Election *election = (Election *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	controller.election = election;
	controller.title = @"Ballot";//election.title;
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
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateElections)];
	self.navigationItem.rightBarButtonItem = reload;
	[reload release];
}

- (void)updateElections {
	NSError *error = nil;
	NSArray *elections = [_client getElections];
	/* TODO: run in background? */
	[_client insertElections:elections withError:&error];
}

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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.navigationItem.rightBarButtonItem = nil;
}


- (void)dealloc {
	self.client = nil;
	[dateFormatter release];
    [super dealloc];
}


@end
