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
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
	
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Position" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
	
    NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"levelOrder" ascending:YES];
	NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"titleOrder" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort1, sort2, nil]];
    [fetchRequest setFetchBatchSize:20];
	
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								  managedObjectContext:_managedObjectContext
																								  sectionNameKeyPath:@"levelOrder"
																								  cacheName:@"DisplayElectionController"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
	
    [sort1 release];
	[sort2 release];
    [fetchRequest release];
    [theFetchedResultsController release];
	
	return _fetchedResultsController;
}


#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
    UITableView *tableView = self.tableView;
	
    switch(type) {
			
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
			
        case NSFetchedResultsChangeMove:
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
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSLog(@"number of rows in section %d", section);
	NSLog(@"%d", [[_fetchedResultsController sections] count]);
	id <NSFetchedResultsSectionInfo> sectionInfo = 
	[[_fetchedResultsController sections] objectAtIndex:section];
	NSLog(@"%d", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *levelOrder = [[[_fetchedResultsController sections] objectAtIndex:section] name];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Position" inManagedObjectContext:_managedObjectContext]];
	[fetchRequest setFetchLimit:1];
	
	NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"levelOrder == %@", [numberFormatter numberFromString:levelOrder]];
	[fetchRequest setPredicate:predicate];
	
	NSString *headerTitle = @"Unknown";
	NSError *error = nil;
	NSArray *fetchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Position *position = (Position *) [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = position.title;
	
	/* query for a ballot vote, if any */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:2];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"BallotVote" inManagedObjectContext:_managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forBallot == %@ && forPosition == %@", ballot, position];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"default";
	
    UITableViewCell *cell = 
	[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] 
				 initWithStyle:UITableViewCellStyleSubtitle 
				 reuseIdentifier:CellIdentifier] autorelease];
    }
	
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Position *position = (Position *) [_fetchedResultsController objectAtIndexPath:indexPath];
	
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
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/* TODO: Handle the error */
		NSLog(@"  DetailedError: %@", [error userInfo]);
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ballot" inManagedObjectContext:_managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchLimit:2];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forElection == %@", election];
	[fetchRequest setPredicate:predicate];
	
	NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
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
			ballot = [(Ballot *) [NSEntityDescription insertNewObjectForEntityForName:@"Ballot" inManagedObjectContext:_managedObjectContext] retain];
			ballot.forElection = election;
			
			if (![_managedObjectContext save:&error])
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
	self.fetchedResultsController = nil;
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
	self.managedObjectContext = nil;
	self.fetchedResultsController.delegate = nil;
	self.fetchedResultsController = nil;
    [super dealloc];
}


@end
