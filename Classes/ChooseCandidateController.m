//
//  ChooseCandidateController.m
//  Supervote
//
//  Created by augusto callejas on 8/25/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Candidate.h"
#import "ChooseCandidateController.h"


@implementation ChooseCandidateController

@synthesize ballot;
@synthesize position;
@synthesize selectedRow;
@synthesize selectedCell;


- (void)loadBallotVote
{
	/* TODO: should the sorting occur here? */
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
	sortedCandidates = [[[position.candidates allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]] retain];
	[sortDescriptor release];
	
	/* query for a ballot vote, if any */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:2];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"BallotVote" inManagedObjectContext:[ballot managedObjectContext]];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forBallot == %@ && forPosition == %@", ballot, position];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [[ballot managedObjectContext] executeFetchRequest:request error:&error];
	if (array != nil)
	{
		NSUInteger count = [array count];
		if (count == 0)
		{
			
		}
		else if (count == 1)
		{
			vote = [(BallotVote *) [array objectAtIndex:0] retain];
			selectedRow = [vote.forCandidate.displayOrder integerValue];
		}
		else
		{
			NSLog(@"NOOO");
		}
	}
	else
	{
		NSLog(@"no!");
	}
	
	[request release];
}

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


#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

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
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
	{
		return position.title;
	}
	
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0)
	{
      return [position.candidates count];
	}
	
	
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *text = @"Title";
	NSString *detailText = @"detail text";
	BOOL selected = NO;
	
	if (indexPath.section == 0)
	{
		Candidate *candidate = (Candidate *) [sortedCandidates objectAtIndex:indexPath.row];
		
		/* TODO: correct to retain and autorelease? */
		text = [[candidate.name retain] autorelease];
		detailText = [[candidate.party retain] autorelease];
		
		if (vote != nil && vote.forCandidate == candidate)
		{
			selected = YES;
		}
	}
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	cell.textLabel.text = text;
	cell.detailTextLabel.text = detailText;
	if (selected)
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/TableView_iPhone/ManageSelections/ManageSelections.html
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (selectedRow != -1 && selectedRow == indexPath.row) {
		/* selected the same candidate, so do nothing */
        return;
    }
    NSIndexPath *oldIndexPath = selectedRow == -1 ? nil : [NSIndexPath indexPathForRow:selectedRow inSection:0];
	
	NSManagedObjectContext *context = [ballot managedObjectContext];
	
    UITableViewCell *newCandidate = [tableView cellForRowAtIndexPath:indexPath];
	newCandidate.accessoryType = UITableViewCellAccessoryCheckmark;
	selectedRow = indexPath.row;
	if (vote == nil)
	{
		vote = [(BallotVote *) [NSEntityDescription insertNewObjectForEntityForName:@"BallotVote" inManagedObjectContext:context] retain];
		vote.forBallot = ballot;
		vote.forPosition = position;
		vote.forCandidate = [sortedCandidates objectAtIndex:selectedRow];
	}
	else {
		vote.forCandidate = [sortedCandidates objectAtIndex:selectedRow];
	}
	
	if (oldIndexPath != nil)
	{
		UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
		oldCell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	NSError *error;
	if (![context save:&error]) {
		NSLog(@"  DetailedError: %@", [error userInfo]);
		NSLog(@"no!");
		// Handle the error
	}
	
	// update the detailed text, because otherwise it stays the same.
	self.selectedCell.detailTextLabel.text = vote.forCandidate.name;
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
}


- (void)dealloc {
	self.ballot = nil;
	self.position = nil;
	self.selectedCell = nil;
	if (vote != nil)
	{
		[vote release];
	}
	if (sortedCandidates != nil)
	{
		[sortedCandidates release];
	}
	[super dealloc];
}


@end

