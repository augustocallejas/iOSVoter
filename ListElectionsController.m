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
//#import "DisplayCombinedElectionController.h"
#import "DisplayElectionController.h"
#import "Election.h"
#import "Measure.h"
#import "Position.h"

@implementation ListElectionsController


#pragma mark -
#pragma mark FetchedResultsBasedTableViewController implementation methods

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
    Election *election = (Election *) [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = election.title;
    cell.detailTextLabel.text = [election.date description];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"users" ofType:@"png"]; 
	UIImage *icon = [UIImage imageWithContentsOfFile:path];
	cell.imageView.image = icon;
}


#pragma mark -
#pragma mark UITableViewDataSource methods

// Overriding the section name creation
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0)
	{
		return @"Elections";
	}
	
	return nil;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// TODO: unnecessarily creating a new controller on each selection!
	DisplayBallotController *controller = [[DisplayBallotController alloc] initWithNibName:@"DisplayBallot" bundle:[NSBundle mainBundle]];
	
	Election *election = (Election *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	controller.election = election;
	controller.title = election.title;
	controller.managedObjectContext = self.managedObjectContext;
	
	[[self navigationController] pushViewController:controller animated:YES];
	[controller release];
	
	//	// TODO: unnecessarily creating a new controller on each selection!
	//	DisplayElectionController *controller = [[DisplayElectionController alloc] initWithNibName:@"DisplayElection" bundle:[NSBundle mainBundle]];
	//	
	//	Election *election = (Election *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	//	controller.election = election;
	//	controller.title = election.title;
	//	controller.managedObjectContext = self.managedObjectContext;
	//	//[controller createSortedPositionsAndBallot];
	//	
	//	[[self navigationController] pushViewController:controller animated:YES];
	//	[controller release];
}


#pragma mark -
#pragma mark UIViewController methods

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
	//[self insertTestData];
}

- (void)insertTestData{
	NSError *error;
	
	// insert data in the context
	
	// Create an election
	Election *election1 = (Election *) [NSEntityDescription insertNewObjectForEntityForName:@"Election" inManagedObjectContext:self.managedObjectContext];
	election1.title = @"2008 General Election";
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"dd-MM-yy";
	election1.date = [dateFormatter dateFromString:@"04-11-08"];
	[dateFormatter release];
	
	Position *position1 = (Position *) [NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:self.managedObjectContext];
	position1.level = @"President of the United States";
	position1.levelOrder = [NSNumber numberWithInt:0];
	position1.title = @"President and Vice President";
	position1.titleOrder = [NSNumber numberWithInt:0];
	[election1 addPositionsObject:position1];
	
	{
		Candidate *candidate1 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:self.managedObjectContext];
		candidate1.name = @"Barack Obama";
		candidate1.party = @"Democratic";
		candidate1.displayOrder = [NSNumber numberWithInt:0];
		candidate1.occupation = nil;
		[position1 addCandidatesObject:candidate1];
		
		Candidate *candidate2 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:self.managedObjectContext];
		candidate2.name = @"John McCain";
		candidate2.party = @"Republican";
		candidate2.displayOrder = [NSNumber numberWithInt:1];
		candidate2.occupation = nil;
		[position1 addCandidatesObject:candidate2];
	}
	
	Position *position2 = (Position *) [NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:self.managedObjectContext];
	position2.level = @"United States Representative";
	position2.levelOrder = [NSNumber numberWithInt:1];
	position2.title = @"9th Congressional District";
	position2.titleOrder = [NSNumber numberWithInt:0];
	[election1 addPositionsObject:position2];
	
	{
		Candidate *candidate1 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:self.managedObjectContext];
		candidate1.name = @"Barbara Lee";
		candidate1.party = @"Democratic";
		candidate1.displayOrder = [NSNumber numberWithInt:0];
		candidate1.occupation = nil;
		[position2 addCandidatesObject:candidate1];
		
		Candidate *candidate2 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:self.managedObjectContext];
		candidate2.name = @"Charles Hargrave";
		candidate2.party = @"Republican";
		candidate2.displayOrder = [NSNumber numberWithInt:1];
		candidate2.occupation = nil;
		[position2 addCandidatesObject:candidate2];
	}
	
	Position *position3 = (Position *) [NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:self.managedObjectContext];
	position3.level = @"District";
	position3.levelOrder = [NSNumber numberWithInt:2];
	position3.title = @"AC Transit District Director, At Large";
	position3.titleOrder = [NSNumber numberWithInt:0];
	[election1 addPositionsObject:position3];
	
	{
		Candidate *candidate1 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:self.managedObjectContext];
		candidate1.name = @"Joyce Roy";
		candidate1.party = nil;
		candidate1.displayOrder = [NSNumber numberWithInt:0];
		candidate1.occupation = @"Retired Architect";
		[position3 addCandidatesObject:candidate1];
		
		Candidate *candidate2 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:self.managedObjectContext];
		candidate2.name = @"H.E. Christian (Chris) Peeples";
		candidate2.party = nil;
		candidate2.displayOrder = [NSNumber numberWithInt:1];
		candidate2.occupation = @"AC Transit At Large Director";
		[position3 addCandidatesObject:candidate2];
	}
	
	Position *position4 = (Position *) [NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:self.managedObjectContext];
	position4.level = @"District";
	position4.levelOrder = [NSNumber numberWithInt:2];
	position4.title = @"AC Transit District Director, Ward 2";
	position4.titleOrder = [NSNumber numberWithInt:1];
	[election1 addPositionsObject:position4];
	
	{
		Candidate *candidate1 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:self.managedObjectContext];
		candidate1.name = @"James Muhammad";
		candidate1.party = nil;
		candidate1.displayOrder = [NSNumber numberWithInt:0];
		candidate1.occupation = @"Paralegal";
		[position4 addCandidatesObject:candidate1];
		
		Candidate *candidate2 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:self.managedObjectContext];
		candidate2.name = @"Greg Harper";
		candidate2.party = nil;
		candidate2.displayOrder = [NSNumber numberWithInt:1];
		candidate2.occupation = @"Incumbent";
		[position4 addCandidatesObject:candidate2];
	}
	
	Position *position5 = (Position *) [NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:self.managedObjectContext];
	position5.level = @"District";
	position5.levelOrder = [NSNumber numberWithInt:2];
	position5.title = @"Bart Director, District 7";
	position5.titleOrder = [NSNumber numberWithInt:2];
	[election1 addPositionsObject:position5];
	
	{
		Candidate *candidate1 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:self.managedObjectContext];
		candidate1.name = @"Marshall Walker III";
		candidate1.party = nil;
		candidate1.displayOrder = [NSNumber numberWithInt:0];
		candidate1.occupation = @"Retired Urban Planner";
		[position5 addCandidatesObject:candidate1];
		
		Candidate *candidate2 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:self.managedObjectContext];
		candidate2.name = @"Lynette Sweet";
		candidate2.party = nil;
		candidate2.displayOrder = [NSNumber numberWithInt:1];
		candidate2.occupation = @"BART Director-District 7";
		[position5 addCandidatesObject:candidate2];
	}
	
	Position *position6 = (Position *) [NSEntityDescription insertNewObjectForEntityForName:@"Position" inManagedObjectContext:self.managedObjectContext];
	position6.level = @"District";
	position6.levelOrder = [NSNumber numberWithInt:2];
	position6.title = @"East Bay Regional Park District Director, Ward 1";
	position6.titleOrder = [NSNumber numberWithInt:3];
	[election1 addPositionsObject:position6];
	
	{
		Candidate *candidate1 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:self.managedObjectContext];
		candidate1.name = @"Norman La Force";
		candidate1.party = nil;
		candidate1.displayOrder = [NSNumber numberWithInt:0];
		candidate1.occupation = @"Lawyer/Law Professor";
		[position6 addCandidatesObject:candidate1];
		
		Candidate *candidate2 = (Candidate *) [NSEntityDescription insertNewObjectForEntityForName:@"Candidate" inManagedObjectContext:self.managedObjectContext];
		candidate2.name = @"Whitney Dotson";
		candidate2.party = nil;
		candidate2.displayOrder = [NSNumber numberWithInt:1];
		candidate2.occupation = @"Regional Park Committeeperson";
		[position6 addCandidatesObject:candidate2];
	}
	
	Measure *measure1 = (Measure *) [NSEntityDescription insertNewObjectForEntityForName:@"Measure" inManagedObjectContext:self.managedObjectContext];
	measure1.identifier = @"1A";
	measure1.title = @"Safe, Reliable High-Speed Passenger Train Bond Act";
	measure1.longDescription = @"To provide Californians a safe...";
	measure1.level = @"Measures submitted to the voters";
	measure1.levelOrder = [NSNumber numberWithInt:0];
	measure1.displayOrder = [NSNumber numberWithInt:0];
	measure1.forElection = election1;
	
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"  DetailedError: %@", [error userInfo]);
		NSLog(@"no!");
		// Handle the error
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

/*
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
 */


- (void)dealloc {
    [super dealloc];
}


@end
