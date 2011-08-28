//
//  ListElectionsController.m
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Candidate.h"
#import "DisplayElectionController.h"
#import "Election.h"
#import "ListElectionsController.h"
#import "Position.h"

@implementation ListElectionsController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

// Adding Core Data to an existing project:
// http://wiresareobsolete.com/wordpress/2009/12/adding-core-data-existing-iphone-projects/
// http://developer.apple.com/library/ios/#documentation/DataManagement/Conceptual/CoreDataSnippets/Introduction/Introduction.html
// This link was instrumental in using the NSFetchedResultsController:
// http://www.raywenderlich.com/999/core-data-tutorial-how-to-use-nsfetchedresultscontroller
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
	
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Election" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
	
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	
    [fetchRequest setFetchBatchSize:20];
	
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								  managedObjectContext:_managedObjectContext
																								  sectionNameKeyPath:nil 
																								  cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
	self.fetchedResultsController.delegate = self;
	
    [sort release];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0)
	{
		return @"Elections";
	}
	
	return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Election *election = (Election *) [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = election.title;
    cell.detailTextLabel.text = [election.date description];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"users" ofType:@"png"]; 
	UIImage *icon = [UIImage imageWithContentsOfFile:path];
	cell.imageView.image = icon;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"default";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
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
	// TODO: unnecessarily creating a new controller on each selection!
	DisplayElectionController *controller = [[DisplayElectionController alloc] initWithNibName:@"DisplayElection" bundle:[NSBundle mainBundle]];
	
	Election *election = (Election *) [_fetchedResultsController objectAtIndexPath:indexPath];
	controller.election = election;
	controller.title = election.title;
	[controller createSortedPositionsAndBallot];
	
	[[self navigationController] pushViewController:controller animated:YES];
	[controller release];
	controller = nil;			
}


#pragma mark -
#pragma mark UIController methods


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		NSLog(@"%p", self);
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
//	if (self.elections == nil)
//	{
//		NSError *error;
//		
//		// insert data in the context
//		
//		// Create an election
//		Election *election1 = (Election *) [NSEntityDescription insertNewObjectForEntityForName:@"Election" inManagedObjectContext:managedObjectContext];
//		election1.title = @"2008 General Election";
//		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//		dateFormatter.dateFormat = @"dd-MM-yy";
//		election1.date = [dateFormatter dateFromString:@"04-11-08"];
//		[dateFormatter release];
//		
//		Position *position1 = (Position *) [NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:managedObjectContext];
//		position1.level = @"President of the United States";
//		position1.title = @"President and Vice President";
//		position1.displayOrder = [NSNumber numberWithInt:0];
//		[election1 addPositionsObject:position1];
//		
//		Candidate *candidate1 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:managedObjectContext];
//		candidate1.name = @"Barack Obama";
//		candidate1.party = @"Democratic";
//		candidate1.displayOrder = [NSNumber numberWithInt:0];
//		candidate1.occupation = nil;
//		[position1 addCandidatesObject:candidate1];
//		
//		Candidate *candidate2 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:managedObjectContext];
//		candidate2.name = @"John McCain";
//		candidate2.party = @"Republican";
//		candidate2.displayOrder = [NSNumber numberWithInt:1];
//		candidate2.occupation = nil;
//		[position1 addCandidatesObject:candidate2];
//		
//		Position *position2 = (Position *) [NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:managedObjectContext];
//		position2.level = @"United States Representative";
//		position2.title = @"9th Congressional District";
//		position2.displayOrder = [NSNumber numberWithInt:1];
//		[election1 addPositionsObject:position2];
//		
//		Candidate *candidate3 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:managedObjectContext];
//		candidate3.name = @"Barbara Lee";
//		candidate3.party = @"Democratic";
//		candidate3.displayOrder = [NSNumber numberWithInt:0];
//		candidate3.occupation = nil;
//		[position2 addCandidatesObject:candidate3];
//		
//		Candidate *candidate4 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:managedObjectContext];
//		candidate4.name = @"Charles Hargrave";
//		candidate4.party = @"Republican";
//		candidate4.displayOrder = [NSNumber numberWithInt:1];
//		candidate4.occupation = nil;
//		[position2 addCandidatesObject:candidate4];
//		
//		if (![managedObjectContext save:&error]) {
//			NSLog(@"  DetailedError: %@", [error userInfo]);
//			NSLog(@"no!");
//			// Handle the error
//		}
//    }
		
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.managedObjectContext = nil;
	self.fetchedResultsController.delegate = nil;
	self.fetchedResultsController = nil;
    [super dealloc];
}


@end
