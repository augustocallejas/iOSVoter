//
//  ChooseCandidateController.m
//  Supervote
//
//  Created by augusto callejas on 8/25/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Candidate.h"
#import "ChooseCandidateController.h"
#import "CandidateViewCell.h"

@implementation ChooseCandidateController

@synthesize ballot;
@synthesize position;
@synthesize selectedRow;
@synthesize selectedCell;


#pragma mark -
#pragma mark FetchedResultsBasedTableViewController implementation methods

- (NSString *)getEntityName{
	return @"Candidate";
}

- (NSString *)getSectionNameKeyPath{
	return nil;
}

- (NSString *)getCacheName{
	return @"ChooseCandidateController";
}

- (NSArray *)allocSortDescriptors{
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    return [NSArray arrayWithObject:sort];
}

- (NSPredicate *)getPredicate{
	return [NSPredicate predicateWithFormat:@"position == %@", position];
}

- (NSString *)getCellIdentifier{
	return @"ChooseCandidateController";
}

- (void)configureCell:(CandidateViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	Candidate *candidate = (Candidate *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.candidateName.text = candidate.name;
	cell.partyName.text = candidate.party;
	
	UIImage *icon = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"users" ofType:@"png"]];
	cell.topFriendIcon.image = icon;
	cell.topEndorsement.text = @"\"I endorse this candidate all the way to the White House!\"";
	
	cell.friendIcon1.image = icon;
	cell.friendIcon2.image = icon;
	cell.friendIcon3.image = icon;
	cell.friendIcon4.image = icon;
	cell.friendIcon5.image = icon;
	cell.friendIcon6.image = icon;
	
	
	//cell.textLabel.text = candidate.name;
	//cell.detailTextLabel.text = candidate.party;
	
	//if (vote != nil && vote.forCandidate == candidate)
	//{
	//	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	//}
	
	/* query for friends' votes on this candidate */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	//[request setFetchLimit:2];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FriendBallotVote" inManagedObjectContext:[ballot managedObjectContext]];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forPosition == %@ && forCandidate == %@", position, candidate];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [[ballot managedObjectContext] executeFetchRequest:request error:&error];
	if (array != nil)
	{
		NSUInteger count = [array count];
		NSLog(@"%d friend(s) for %@", count, candidate.name);
//		if (count == 0)
//		{
//		}
//		else if (count == 1)
//		{
//			vote = [(BallotVote *) [array objectAtIndex:0] retain];
//			selectedRow = [vote.forCandidate.displayOrder integerValue];
//		}
//		else
//		{
//			NSLog(@"NOOO");
//		}
	}
	else
	{
		NSLog(@"no!");
	}
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

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	self = [super initWithNibName:nibName bundle:nibBundle];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	socialBallotView = [prefs boolForKey:@"SocialBallotMode"];
	if (self) {
		//self.tableView.rowHeight = 176;
		UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Compact", @"Friends", nil]];
		control.segmentedControlStyle = UISegmentedControlStyleBar;
		control.selectedSegmentIndex = socialBallotView ? 1 : 0;
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
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if ([segCtl selectedSegmentIndex] == 0) {
		socialBallotView = NO;
	}
	else {
		socialBallotView = YES;
	}
	[prefs setBool:socialBallotView forKey:@"SocialBallotMode"];
	if (![prefs synchronize]) {
		NSLog(@"Did not synchronize correctly");
	}
	
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
	{
		return position.title;
	}
	
	return nil;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // If our cell is selected, return double height
    //if([self cellIsSelected:indexPath]) {
	if (socialBallotView == YES) {
        return 176;
    }
	
    // Cell isn't selected so return single height
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Candidate *candidate = (Candidate *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	// http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/TableView_iPhone/ManageSelections/ManageSelections.html
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (selectedRow != -1 && selectedRow == indexPath.row) {
		/* selected the same candidate, so do nothing */
        return;
    }
    NSIndexPath *oldIndexPath = selectedRow == -1 ? nil : [NSIndexPath indexPathForRow:selectedRow inSection:0];
		
    UITableViewCell *newCandidate = [tableView cellForRowAtIndexPath:indexPath];
	newCandidate.accessoryType = UITableViewCellAccessoryCheckmark;
	selectedRow = indexPath.row;
	if (vote == nil) {
		vote = [(BallotVote *) [NSEntityDescription insertNewObjectForEntityForName:@"BallotVote" inManagedObjectContext:self.managedObjectContext] retain];
		vote.forBallot = ballot;
		vote.forPosition = position;
		vote.forCandidate = candidate;
	}
	else {
		vote.forCandidate = candidate;
	}
	
	if (oldIndexPath != nil)
	{
		UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
		oldCell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	NSError *error;
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"  DetailedError: %@", [error userInfo]);
		NSLog(@"no!");
		// Handle the error
	}
	
	// update the detailed text, because otherwise it stays the same.
	self.selectedCell.candidateName.text = vote.forCandidate.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CandidateViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"CandidateViewCell" owner:nil options:nil];
		
		for (id nibObject in nibObjects) {
			if ([nibObject isKindOfClass:[CandidateViewCell class]]) {
				cell = (CandidateViewCell *)nibObject;
				break;
			}
		}
	}
	
	[self configureCell:(CandidateViewCell *) cell atIndexPath:indexPath];
	
    return cell;
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
	if (vote != nil)
	{
		[vote release];
		vote = nil;
	}
}


- (void)dealloc {
	self.ballot = nil;
	self.position = nil;
	self.selectedCell = nil;
	if (vote != nil)
	{
		[vote release];
	}
	[super dealloc];
}


@end

