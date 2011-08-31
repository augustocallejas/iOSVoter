//
//  DisplayElectionController.m
//  Supervote
//
//  Created by augusto callejas on 8/9/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Ballot.h"
#import "BallotVote.h"
#import "Candidate.h"
#import "ChooseCandidateController.h"
#import "DisplayElectionController.h"
#import "Position.h"

@implementation DisplayElectionController

@synthesize election;

#pragma mark -
#pragma mark FetchedResultsBasedTableViewController implementation methods

- (NSString *)getEntityName{
	return @"Position";
}

- (NSString *)getSectionNameKeyPath{
	return @"levelOrder";
}

- (NSString *)getCacheName{
	return @"DisplayElectionController";
}

- (NSArray *)allocSortDescriptors{
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"levelOrder" ascending:YES];
	NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"titleOrder" ascending:YES];
    return [NSArray arrayWithObjects:sort1, sort2, nil];
}

- (NSPredicate *)getPredicate{
	return [NSPredicate predicateWithFormat:@"election == %@", election];
}

- (NSString *)getCellIdentifier{
	return @"DisplayElectionController";
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Position *position = (Position *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = position.title;
	
	/* TODO: break this functionality out into a method that ChooseCandidate can use, or save references? */
	/* query for a ballot vote, if any */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:2];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"BallotVote" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forBallot == %@ && forPosition == %@", ballot, position];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (array != nil)
	{
		NSUInteger count = [array count];
		if (count == 0)
		{
			cell.detailTextLabel.text = @"<Not selected>";
		}
		else if (count == 1)
		{
			Candidate *candidate = ((BallotVote *) [array objectAtIndex:0]).forCandidate;
			if (candidate != nil) {
				cell.detailTextLabel.text = candidate.name;
			}
			else {
				cell.detailTextLabel.text = @"Undecided";
			}
		}
		else
		{
			NSLog(@"Should have only one vote!");
		}
	}
	else
	{
		/* TODO: Handle the error */
		NSLog(@"  DetailedError: %@", [error userInfo]);
	}
	
	[request release];
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *levelOrder = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Position" inManagedObjectContext:self.managedObjectContext]];
	[fetchRequest setFetchLimit:1];
	
	NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"levelOrder == %@", [numberFormatter numberFromString:levelOrder]];
	[fetchRequest setPredicate:predicate];
	
	NSString *headerTitle = @"Unknown";
	NSError *error = nil;
	NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if ([fetchResults count] > 0) {
		Position *position =  (Position *)[fetchResults objectAtIndex:0];
		//headerView.titleLabel.text = position.level;
		headerTitle = [[position.level retain] autorelease];
	} else {
		/* TODO: print error? */
	}
	
	[numberFormatter release];
	[fetchRequest release];

	return headerTitle;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Position *position = (Position *) [self.fetchedResultsController objectAtIndexPath:indexPath];
		
	// TODO: unnecessarily creating a new controller on each selection!
	ChooseCandidateController *controller = [[ChooseCandidateController alloc] initWithNibName:@"ChooseCandidate" bundle:[NSBundle mainBundle]];
	controller.selectedRow = -1;
	controller.ballot = ballot;
	controller.position = position;
	controller.managedObjectContext = self.managedObjectContext;
	controller.title = position.level;
	controller.selectedCell = [tableView cellForRowAtIndexPath:indexPath];

	[[self navigationController] pushViewController:controller animated:YES];
	[controller release];
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ballot" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchLimit:2];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forElection == %@", election];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil)
	{
		/* TODO: Handle the error */
		NSLog(@"  DetailedError: %@", [error userInfo]);
	}
	else
	{
		if ([fetchedObjects count] == 0)
		{
			// create a ballot for this election
			ballot = [(Ballot *) [NSEntityDescription insertNewObjectForEntityForName:@"Ballot" inManagedObjectContext:self.managedObjectContext] retain];
			ballot.forElection = election;
			
			if (![self.managedObjectContext save:&error])
			{
				/* TODO: Handle the error */
				NSLog(@"  DetailedError: %@", [error userInfo]);
			}
		}
		else if ([fetchedObjects count] == 1)
		{
			ballot = [(Ballot *) [fetchedObjects objectAtIndex:0] retain];
		}
		else {
			NSLog(@"Too many ballots?");
		}
	}
	
	[fetchRequest release];
}


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
	if (ballot != nil)
	{
		[ballot release];
	}
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[election release];
	if (ballot != nil)
	{
		[ballot release];
	}
    [super dealloc];
}


@end
