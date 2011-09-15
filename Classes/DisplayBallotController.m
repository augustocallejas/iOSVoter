//
//  DisplayBallotController.m
//  Supervote
//
//  Created by augusto callejas on 9/1/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "DisplayBallotController.h"

#import "BallotVote.h"
#import "ChooseCandidateController.h"
#import "Candidate.h"
#import "Measure.h"
#import "MeasureVote.h"
#import "Position.h"
#import "PositionViewCell.h"
#import "VoteMeasureController.h"

@implementation DisplayBallotController

@synthesize election = _election;
@synthesize ballot = _ballot;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController1 = _fetchedResultsController1;
@synthesize fetchedResultsController2 = _fetchedResultsController2;


#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	self = [super initWithNibName:nibName bundle:nibBundle];
	singleUserView = YES;
	if (self) {
		UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Compact", @"Friends", nil]];
		control.segmentedControlStyle = UISegmentedControlStyleBar;
		control.selectedSegmentIndex = 0;
		[control addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
		self.navigationItem.titleView = control;
		[control release];
	}
	
	return self;
}

- (void)segmentAction:(id)sender
{
	UISegmentedControl* segCtl = sender;
	// the segmented control was clicked, handle it here 
	//NSLog(@"segment clicked %d", [segCtl selectedSegmentIndex]);
	if ([segCtl selectedSegmentIndex] == 0) {
		singleUserView = YES;
	}
	else {
		singleUserView = NO;
	}
	
	//reloadRowsAtIndexPath
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
	//[self.tableView reloadRowsAtIndexPaths:[self.tableView visibleCells] withRowAnimation:UITableViewRowAnimationNone];
	//[self.tableView reloadData];
}

- (void)animationStopped:(id)sender {
	NSLog(@"animation");
}

- (NSFetchedResultsController *)fetchedResultsController1 {
    if (_fetchedResultsController1 != nil) {
        return _fetchedResultsController1;
    }
	
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Position" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"levelOrder" ascending:YES];
	NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"titleOrder" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort1, sort2, nil]];

    [fetchRequest setFetchBatchSize:20];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"forElection == %@", self.election]];

    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								  managedObjectContext:_managedObjectContext
																									sectionNameKeyPath:@"levelOrder"
																											 cacheName:@"DisplayBallotController-Position"];
    self.fetchedResultsController1 = theFetchedResultsController;
	self.fetchedResultsController1.delegate = self;
	
	[sort1 release];
	[sort2 release];
    [fetchRequest release];
    [theFetchedResultsController release];
	
    return _fetchedResultsController1;    
}

- (NSFetchedResultsController *)fetchedResultsController2 {
    if (_fetchedResultsController2 != nil) {
        return _fetchedResultsController2;
    }
	
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Measure" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
	
	NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"levelOrder" ascending:YES];
	NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort1, sort2, nil]];

    [fetchRequest setFetchBatchSize:20];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"forElection == %@", self.election]];
	
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								  managedObjectContext:_managedObjectContext
																									sectionNameKeyPath:@"levelOrder"
																											 cacheName:@"DisplayBallotController-Measure"];
    self.fetchedResultsController2 = theFetchedResultsController;
	self.fetchedResultsController2.delegate = self;
	
	[sort1 release];
	[sort2 release];
    [fetchRequest release];
    [theFetchedResultsController release];
	
    return _fetchedResultsController2;    
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section < [self.fetchedResultsController1.sections count]) {
		[self configureCellAsPosition:(PositionViewCell *) cell atIndexPath:indexPath];
	}
	else {
		[self configureCellAsMeasure:cell atIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section-[self.fetchedResultsController1.sections count])]];
	}
}

- (void)configureCellAsPosition:(PositionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"Configure %d %d", [indexPath section], [indexPath row]);
    Position *position = (Position *) [self.fetchedResultsController1 objectAtIndexPath:indexPath];
	cell.positionTitle.text = position.title;
	
//	if (singleUserView) {
//		cell.friendIcon1.image = nil;
//		cell.friendIcon2.image = nil;
//		cell.friendIcon3.image = nil;
//		cell.friendIcon4.image = nil;
//		cell.friendIcon5.image = nil;
//		cell.friendIcon6.image = nil;
//	}
	//else {
		NSString *path = [[NSBundle mainBundle] pathForResource:@"users" ofType:@"png"]; 
		UIImage *icon = [UIImage imageWithContentsOfFile:path];
		
//		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//		NSString *documentsDirectory = [paths objectAtIndex:0];
//		NSString *pathToCandidateIcon = [NSString stringWithFormat:@"%@/images/A000014.jpg", documentsDirectory];
//		UIImage *candidateIcon = [UIImage imageWithContentsOfFile:pathToCandidateIcon];
		
		//cell.candidateIcon.image = candidateIcon;
		cell.friendIcon1.image = icon;
		cell.friendIcon2.image = icon;
		cell.friendIcon3.image = icon;
		cell.friendIcon4.image = icon;
		cell.friendIcon5.image = icon;
		cell.friendIcon6.image = icon;
	//}

	
	/* TODO: break this functionality out into a method that ChooseCandidate can use, or save references? */
	/* query for a ballot vote, if any */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:2];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"BallotVote" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forBallot == %@ && forPosition == %@", self.ballot, position];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (array != nil)
	{
		NSUInteger count = [array count];
		if (count == 0)
		{
			cell.candidateName.text = @"<Not selected>";
		}
		else if (count == 1)
		{
			Candidate *candidate = ((BallotVote *) [array objectAtIndex:0]).forCandidate;
			if (candidate != nil) {
				cell.candidateName.text = candidate.name;
			}
			else {
				cell.candidateName.text = @"Undecided";
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

- (void)configureCellAsMeasure:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Measure *measure = (Measure *) [self.fetchedResultsController2 objectAtIndexPath:indexPath];
    cell.textLabel.text = measure.title;
	
	/* TODO: break this functionality out into a method that ChooseCandidate can use, or save references? */
	/* query for a measure vote, if any */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:2];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MeasureVote" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forBallot == %@ && forMeasure == %@", self.ballot, measure];
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
			NSNumber *vote = ((MeasureVote *) [array objectAtIndex:0]).vote;
			if (vote != nil) {
				if ([vote boolValue]) {
					cell.detailTextLabel.text = @"YES";
				}
				else {
					cell.detailTextLabel.text = @"NO";
				}
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
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	self.tableView.rowHeight = 88;

	NSError *error;
	if (![[self fetchedResultsController1] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
	
	if (![[self fetchedResultsController2] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
	
	/* create a ballot */
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ballot" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchLimit:2];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forElection == %@", self.election];
	[fetchRequest setPredicate:predicate];
	
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
			self.ballot = (Ballot *) [NSEntityDescription insertNewObjectForEntityForName:@"Ballot" inManagedObjectContext:self.managedObjectContext];
			self.ballot.forElection = self.election;
			
			if (![self.managedObjectContext save:&error])
			{
				/* TODO: Handle the error */
				NSLog(@"  DetailedError: %@", [error userInfo]);
			}
		}
		else if ([fetchedObjects count] == 1)
		{
			self.ballot = (Ballot *) [fetchedObjects objectAtIndex:0];
		}
		else {
			NSLog(@"Too many ballots?");
		}
	}
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController1.sections count] + [self.fetchedResultsController2.sections count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
	if (section < [self.fetchedResultsController1.sections count]) {
		return [self tableView:tableView titleForPositionHeaderInSection:section];
	}
	
	return [self tableView:tableView titleForMeasureHeaderInSection:section-[self.fetchedResultsController1.sections count]];
}


- (NSString *)tableView:(UITableView *)tableView titleForPositionHeaderInSection:(NSInteger)section{
	NSString *levelOrder = [[self.fetchedResultsController1.sections objectAtIndex:section] name];
	
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


- (NSString *)tableView:(UITableView *)tableView titleForMeasureHeaderInSection:(NSInteger)section
{
	NSString *levelOrder = [[self.fetchedResultsController2.sections objectAtIndex:section] name];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Measure" inManagedObjectContext:self.managedObjectContext]];
	[fetchRequest setFetchLimit:1];
	
	NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"levelOrder == %@", [numberFormatter numberFromString:levelOrder]];
	[fetchRequest setPredicate:predicate];
	
	NSString *headerTitle = @"Unknown";
	NSError *error = nil;
	NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if ([fetchResults count] > 0) {
		Measure *measure =  (Measure *)[fetchResults objectAtIndex:0];
		headerTitle = [[measure.level retain] autorelease];
	} else {
		/* TODO: print error? */
	}
	
	[numberFormatter release];
	[fetchRequest release];
	
	return headerTitle;
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
	static NSString *positionID = @"PositionViewCell";
    static NSString *CellIdentifier = @"DisplayBallotController";
    UITableViewCell *cell = nil;
	
	if ([indexPath section] < [self.fetchedResultsController1.sections count]) {
		cell = [tableView dequeueReusableCellWithIdentifier:positionID];
		if (cell == nil) {
			
			NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"PositionViewCell" owner:nil options:nil];
			
			for (id nibObject in nibObjects) {
				if ([nibObject isKindOfClass:[PositionViewCell class]]) {
					cell = (PositionViewCell *)nibObject;
					break;
				}
			}
		}
		
		[self configureCellAsPosition:(PositionViewCell *) cell atIndexPath:indexPath];
	}
	else {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		}
		
		// Configure the cell...
		[self configureCell:cell atIndexPath:indexPath];
	}
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section < [self.fetchedResultsController1.sections count]) {
		Position *position = (Position *) [self.fetchedResultsController1 objectAtIndexPath:indexPath];
		
		// TODO: unnecessarily creating a new controller on each selection!
		ChooseCandidateController *controller = [[ChooseCandidateController alloc] initWithNibName:@"ChooseCandidate" bundle:[NSBundle mainBundle]];
		controller.selectedRow = -1;
		controller.ballot = self.ballot;
		controller.position = position;
		controller.managedObjectContext = self.managedObjectContext;
		controller.title = position.level;
		controller.selectedCell = (PositionViewCell *) [tableView cellForRowAtIndexPath:indexPath];
		
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
	else {
		NSIndexPath *correctIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section-[self.fetchedResultsController1.sections count])];
		Measure *measure = (Measure *) [self.fetchedResultsController2 objectAtIndexPath:correctIndexPath];
		
		// TODO: unnecessarily creating a new controller on each selection!
		VoteMeasureController *controller = [[VoteMeasureController alloc] initWithNibName:@"VoteMeasure" bundle:[NSBundle mainBundle]];
		controller.ballot = self.ballot;
		controller.measure = measure;
		controller.selectedCell = [tableView cellForRowAtIndexPath:indexPath];
		controller.title = [NSString stringWithFormat:@"Measure %@", measure.identifier];
		
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // If our cell is selected, return double height
    //if([self cellIsSelected:indexPath]) {
	if (singleUserView == NO) {
        return 88;
    }
	
    // Cell isn't selected so return single height
	return 44;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}



- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[super viewDidLoad];
	self.fetchedResultsController1.delegate = nil;
	self.fetchedResultsController1 = nil;
	self.fetchedResultsController2.delegate = nil;
	self.fetchedResultsController2 = nil;
}


- (void)dealloc {
	self.election = nil;
	self.ballot = nil;
	self.fetchedResultsController1.delegate = nil;
	self.fetchedResultsController1 = nil;
	self.fetchedResultsController2.delegate = nil;
	self.fetchedResultsController2 = nil;
    [super dealloc];
}


@end

