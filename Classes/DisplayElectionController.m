//
//  DisplayElectionController.m
//  Supervote
//
//  Created by augusto callejas on 8/9/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Ballot.h"
#import "ChooseCandidateController.h"
#import "DisplayElectionController.h"
#import "Position.h"

@implementation DisplayElectionController

@synthesize election;

- (void)createSortedPositionsAndBallot
{
	/* TODO: should the sorting occur here? */
	if (sortedPositions == nil)
	{
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
		sortedPositions = [[[election.positions allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]] retain];
		[sortDescriptor release];
	}
	
	// Custom initialization.
	NSManagedObjectContext *managedObjectContext = [election managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ballot" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil)
	{
		// Handle the error
		NSLog(@"no!");
	}
	else
	{
		if ([fetchedObjects count] == 0)
		{
			// create a ballot for this election
			ballot = [(Ballot *) [NSEntityDescription insertNewObjectForEntityForName:@"Ballot" inManagedObjectContext:managedObjectContext] retain];
			ballot.forElection = election;
			
			if (![managedObjectContext save:&error])
			{
				NSLog(@"  DetailedError: %@", [error userInfo]);
				NSLog(@"no!");
				// Handle the error
			}
		}
		else
		{
			ballot = [(Ballot *) [fetchedObjects objectAtIndex:0] retain];
		}
		
	}
	
	[fetchRequest release];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [election.positions count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section < [election.positions count])
	{
		return 1;
	}
	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section < [election.positions count])
	{
		Position *position = [sortedPositions objectAtIndex:section];
		return position.level;
	}
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
	
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"default"] autorelease];
	}
	
	if (indexPath.section < [election.positions count] && indexPath.row == 0)
	{
		Position *position = (Position *) [sortedPositions objectAtIndex:indexPath.section];
		
		cell.textLabel.text = position.title;
		
		/* TODO: is there a BallotVote for this Ballot & Position? */
		cell.detailTextLabel.text = @"Undecided";
	}
	else
	{
		cell.textLabel.text = @"No text";
		cell.detailTextLabel.text = @"No detail text";
	}
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"users" ofType:@"png"];
	cell.imageView.image = [UIImage imageWithContentsOfFile:path];
	
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	/* Only one section */
	if (indexPath.section < [election.positions count] && indexPath.row == 0)
	{
		Position *position = [sortedPositions objectAtIndex:indexPath.section];
		
		// TODO: unnecessarily creating a new controller on each selection!
		ChooseCandidateController *controller = [[ChooseCandidateController alloc] initWithNibName:@"ChooseCandidate" bundle:[NSBundle mainBundle]];
		controller.selectedRow = -1;
		controller.ballot = ballot;
		controller.position = position;
		controller.title = position.level;
		[controller loadBallotVote];
		[[self navigationController] pushViewController:controller animated:YES];
		[controller release];		
	}
}

//// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//
//    }
//    return self;
//}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[election release];
	if (ballot != nil)
	{
		[ballot release];
	}
	if (sortedPositions != nil)
	{
		[sortedPositions release];
	}
}


@end
