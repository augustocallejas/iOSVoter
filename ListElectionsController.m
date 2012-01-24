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
	return nil;
}

- (NSArray *)allocSortDescriptors{
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	return [NSArray arrayWithObject:sort];
}

- (NSPredicate *)getPredicate{
	return nil;
}

- (NSString *)getCellIdentifier{
	return @"ListElectionsController";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	cell.textLabel.minimumFontSize = 13.0;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
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

/* TODO: run in background? */
/* TODO: doesn't manage deleted elections or past elections */
- (void)updateElections {
	vote_status status = OK;
	NSDictionary *elections = [_client getElections:&status];
	
	if (elections == nil) {
		/* nil means we couldn't contact the server */
		NSString *title = nil;
		NSString *message = nil;
		switch (status) {
			case HTTP_ERROR:
				title = @"Network Error";
				message = @"Unable to connect to server, please verify your network connection and try again.";
				break;
			case SERVER_ERROR:
				title = @"Server Error";
				message = @"Unable to retrieve elections from server, please try again in a few minutes.";
				break;
			case BAD_REQUEST:
				title = @"Bad Request";
				message = @"The app sent a bad request to the server.";
				break;
			case UNEXPECTED_RESPONSE:
			default:
				title = @"Unexpected Response";
				message	= @"The server returned an unexpected response.";
				break;
		}
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
														message:message 
													   delegate:nil 
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else {
		NSError *httpError = nil;
		for (NSString *electionGuid in elections) {
			double timestamp = [((NSNumber *)[elections objectForKey:electionGuid]) doubleValue] / 1000.0;
			NSDate *lastModified = [NSDate dateWithTimeIntervalSince1970:timestamp];
			NSDate *newLastModified = nil;
			Election *electionObj = [_client getObject:@"Election" byGuid:electionGuid];
			httpError = nil;
			
			if (electionObj == nil || [electionObj.lastModified timeIntervalSinceDate:lastModified] <= -1.0) {
				/* get election from server */
				NSDictionary *election = [_client getElection:electionGuid
											 withLastModified:nil
										  withNewModifiedTime:&newLastModified
													withError:&httpError];
				
				if (httpError != nil) {
					NSLog(@"Network error while fetching election: %@", [httpError userInfo]);
				}
				else if (electionObj == nil) {
					NSLog(@"Election '%@' not in database, going to fetch it", electionGuid);
					
					if (election != nil) {
						NSError *storeError = nil;
						if (![_client insertElection:election withLastModified:newLastModified withError:&storeError]) {
							if (storeError != nil) {
								NSLog(@"Storage error while inserting election: %@", [storeError userInfo]);
							}
						}
					}
				}
				else {
					NSLog(@"Election '%@' needs updates (local %@ versus server %@)", electionGuid, electionObj.lastModified, lastModified);
					
					if (election != nil) {
						NSError *storeError = nil;
						if (![_client updateElection:electionObj withObject:election withLastModified:lastModified withError:&storeError]) {
							if (storeError != nil) {
								NSLog(@"Storage error while updating election: %@", [storeError userInfo]);
							}
						}
					}
				}
			}
			else {
				NSLog(@"Election '%@' up to date, no updates necessary", electionGuid);
			}
		}
		
		/* TODO: do this somewhere else!!!! */
		NSError *storeError = nil;
		NSArray *friends = [_client getFriends];
		if (friends != nil) {
			[_client insertFriends:friends withError:&storeError];
			
			if (storeError != nil) {
				NSLog(@"Store error while inserting friends: %@", [storeError userInfo]);
			}
		}
		
		for (NSString *electionGuid in elections) {
			NSArray *votes = [_client getVotesForBallot:electionGuid];
			if (votes != nil) {
				[_client insertVotes:votes];
			}
		}
	}
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
