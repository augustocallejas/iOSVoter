//
//  VoteMeasureController.m
//  Supervote
//
//  Created by augusto callejas on 9/1/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "VoteMeasureController.h"

#import "Friend.h"
#import "FriendMeasureVote.h"
#import "ListEndorsementsController.h"
#import "MeasureViewCell.h"

@implementation VoteMeasureController

@synthesize ballot = _ballot;
@synthesize measure = _measure;
@synthesize vote = _vote;
@synthesize selectedCell = _selectedCell;

//static NSNumber *YES_VOTE = [NSNumber numberWithBool:YES];
//static NSNumber *NO_VOTE = [NSNumber numberWithBool:NO];
//static NSNumber *UNDECIDED_VOTE = nil;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	socialBallotView = [prefs boolForKey:@"SocialBallotMode"];
    if (self) {
        // Custom initialization.
		UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Compact", @"Expanded", nil]];
		control.segmentedControlStyle = UISegmentedControlStyleBar;
		control.selectedSegmentIndex = socialBallotView ? 1 : 0;
		[control addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
		self.navigationItem.titleView = control;
		[control release];
		//		self.tableView.allowsSelection = NO;
		//		[self.tableView setAllowsSelection:NO];
		//		[self.tableView allowsSelection:NO];
    }
    return self;
}

- (void)segmentAction:(id)sender {
	UISegmentedControl* segCtl = sender;
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.allowsSelection = NO;
	
	/* query for a measure vote, if any */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:2];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MeasureVote" inManagedObjectContext:[self.ballot managedObjectContext]];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forBallot == %@ && forMeasure == %@", self.ballot, self.measure];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *array = [[self.ballot managedObjectContext] executeFetchRequest:request error:&error];
	if (array != nil)
	{
		NSUInteger count = [array count];
		if (count == 0)
		{
		}
		else if (count == 1)
		{
			self.vote = (MeasureVote *) [array objectAtIndex:0];
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
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Custom button actions

- (void)voteOnMeasure:(id)sender{
	NSNumber *voteSelected = nil;
	UIButton *button = (UIButton *)sender;
	if (button.tag == 0) {
		/* YES */
		voteSelected = [NSNumber numberWithBool:YES];
	}
	else if (button.tag == 1) {
		/* NO */
		voteSelected = [NSNumber numberWithBool:NO];
	}
	else if (button.tag == 2) {
		/* Undecided */
		voteSelected = nil;
	}
	
	CreateEndorsementViewController *controller = [[CreateEndorsementViewController alloc] initWithNibName:@"CreateEndorsementViewController" bundle:[NSBundle mainBundle]];
	controller.delegate = self;
	controller.measure = _measure;
	controller.measureVote = voteSelected;
	if (_vote != nil) {
		if ((_vote.vote == nil && voteSelected == nil) ||
			(_vote.vote != nil && voteSelected != nil && [voteSelected boolValue] == [_vote.vote boolValue]))
		{
			controller.statement = _vote.statement;
		}
	}
	
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (void)didDismissModalView:(BOOL)withVote toCandidate:(Candidate *)candidate orMeasureVote:(NSNumber *)measureVote withOptionalStatement:(NSString *)statement {
	if (withVote) {
		if (_vote == nil) {			
			self.vote = (MeasureVote *) [NSEntityDescription insertNewObjectForEntityForName:@"MeasureVote" inManagedObjectContext:[_ballot managedObjectContext]];
			_vote.forBallot = _ballot;
			_vote.forMeasure = _measure;
		}
//		NSLog(@"Vote: %@", measureVote);
		NSLog(@"Saving vote: %@, %@", measureVote, statement);
		_vote.vote = measureVote;
		_vote.statement = statement;
		
		NSError *error;
		if (![[self.ballot managedObjectContext] save:&error]) {
			NSLog(@"  DetailedError: %@", [error userInfo]);
			// Handle the error
		}
		
		// update the detailed text, because otherwise it stays the same.
		self.selectedCell.minorTitle.text = [MeasureViewCell voteToString:measureVote];
		
		/* TODO: does this reload all cells, or only visible ones? */
		[self.tableView reloadData];
	}
	else {
		NSLog(@"User canceled their vote selection");
	}
	
    // Dismiss the modal view controller
    [self dismissModalViewControllerAnimated:YES];	
}

- (IBAction)viewAllEndorsements:(id)sender{	
	NSNumber *voteSelected = nil;
	UIButton *button = (UIButton *)sender;
	if (button.tag == 0) {
		/* YES */
		voteSelected = [NSNumber numberWithBool:YES];
	}
	else if (button.tag == 1) {
		/* NO */
		voteSelected = [NSNumber numberWithBool:NO];
	}
	else if (button.tag == 2) {
		/* Undecided */
		voteSelected = nil;
	}
	
	NSLog(@"Vote selected to view %@", voteSelected);
	
	ListEndorsementsController *controller = [[ListEndorsementsController alloc] init];//initWithNibName:@"VoteMeasure" bundle:[NSBundle mainBundle]];
	//controller.position = self.position;
	//controller.candidate = candidate;
	controller.measure = _measure;
	controller.vote = voteSelected;
	controller.title = @"Endorsements";
	controller.managedObjectContext = [_ballot managedObjectContext];
	
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0)
	{
		return self.measure.title;
	}
	
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"MeasureViewCell";
    MeasureViewCell *cell = (MeasureViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
		
		for (id nibObject in nibObjects) {
			if ([nibObject isKindOfClass:[MeasureViewCell class]]) {
				cell = (MeasureViewCell *)nibObject;
				break;
			}
		}
	}
	
//	NSString *CellIdentifier = @"VoteMeasureController";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
//    }
	
	BOOL selected = NO;
    
    // Configure the cell...
	if (indexPath.row == 0) {
		cell.measureName.text = @"YES";
		if (_vote != nil && _vote.vote != nil && [_vote.vote boolValue] == YES)
		{
			selected = YES;
		}
	}
	else if (indexPath.row == 1) {
		cell.measureName.text = @"NO";
		if (_vote != nil && _vote.vote != nil && [_vote.vote boolValue] == NO)
		{
			selected = YES;
		}
	}
	else if (indexPath.row == 2) {
		cell.measureName.text = @"Undecided";
		if (_vote != nil && _vote.vote == nil)
		{
			selected = YES;
		}
	}
	
	cell.editEndorsement.tag = indexPath.row;
	cell.voteMeasure.tag = indexPath.row;
	cell.viewAllEndorsements.tag = indexPath.row;
	
	if (selected) {
		[cell.editEndorsement setTitle:@"Edit endorsement" forState:UIControlStateNormal];
		UIImage *icon = [UIImage imageNamed:@"checked.png"];
		cell.voteStatus.image = icon;
	}
	else {
		[cell.editEndorsement setTitle:@"" forState:UIControlStateNormal];
		UIImage *icon = [UIImage imageNamed:@"unchecked.png"];
		cell.voteStatus.image = icon;
	}
	
	/* query for friends' votes on this measure */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FriendMeasureVote" inManagedObjectContext:[self.ballot managedObjectContext]];
	[request setEntity:entity];
	
	NSNumber* currVote = nil;
	if (indexPath.row == 0) {
		currVote = [NSNumber numberWithBool:YES];
	}
	else if (indexPath.row == 1) {
		currVote = [NSNumber numberWithBool:NO];
	}
	else if (indexPath.row == 2) {
		currVote = nil;
	}
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forMeasure == %@ && vote == %@", self.measure, currVote];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSUInteger count = [[self.ballot managedObjectContext] countForFetchRequest:request error:&error];
	if (error == nil) {
//		NSUInteger orgCount = 0;
//		NSString *string = [NSString stringWithFormat:@"%d friend%@, %d organization%@", count, count==1?@"":@"s", orgCount, orgCount==1?@"":@"s"];
		NSString *string = [NSString stringWithFormat:@"%d friend%@", count, count==1?@"":@"s"];
		[cell.viewAllEndorsements setTitle:string forState:UIControlStateNormal];
		
		CGSize stringsize = [string sizeWithFont:[UIFont boldSystemFontOfSize:14]]; 
		[cell.viewAllEndorsements setFrame:CGRectMake(12, 45, stringsize.width+10, stringsize.height)];
	}
	else {
		/* TODO: log error */
		NSLog(@"No");
	}
	
	/* fill in the top endorsements */
	[request setFetchLimit:3];
	
	NSArray *array = [[self.ballot managedObjectContext] executeFetchRequest:request error:&error];
	if (error == nil) {
		FriendMeasureVote *friendVote;
		NSUInteger count = [array count];
		
		if (count > 0) {
			friendVote = (FriendMeasureVote *) [array objectAtIndex:0];
			cell.friendEndorsement1.text = friendVote.statement;

			if (count > 1) {
				friendVote = (FriendMeasureVote *) [array objectAtIndex:1];
				cell.friendEndorsement2.text = friendVote.statement;

				if (count > 2) {
					friendVote = (FriendMeasureVote *) [array objectAtIndex:2];
					cell.friendEndorsement3.text = friendVote.statement;
				}
			}
		}
	}
	else {
		/* TODO: log error */
		NSLog(@"No");
	}

	/* TODO: this code is stand in for now... */
	UIImage *icon = [UIImage imageNamed:@"users.png"];	
	cell.friendIcon1.image = icon;
	cell.friendIcon2.image = icon;
	cell.friendIcon3.image = icon;
	
	[request release];
	
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (socialBallotView == YES) {
        return 176;
		//return 103;
		//return 158;
    }
	
	return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// 0 = YES 1 = NO 2 = UNDECIDED
	NSUInteger selected = indexPath.row;
	
	// http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/TableView_iPhone/ManageSelections/ManageSelections.html
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (_vote != nil) {
		if ((_vote.vote == nil && selected == 2) ||
			(_vote.vote != nil && [_vote.vote boolValue] == YES && selected == 0) ||
			(_vote.vote != nil && [_vote.vote boolValue] == NO && selected == 1))
		{
			/* TODO: statement may have changed??? */
			return;
		}
	}
	
    NSIndexPath *oldIndexPath;
	if (_vote == nil) {
		oldIndexPath = nil;
	}
	else if (_vote.vote == nil) {
		oldIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
	}
	else if ([_vote.vote boolValue]) {
		oldIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	}
	else {
		oldIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
	}

			 
    UITableViewCell *newCandidate = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selected inSection:0]];
	newCandidate.accessoryType = UITableViewCellAccessoryCheckmark;
	if (_vote == nil) {
		self.vote = (MeasureVote *) [NSEntityDescription insertNewObjectForEntityForName:@"MeasureVote" inManagedObjectContext:[_ballot managedObjectContext]];
		_vote.forBallot = _ballot;
		_vote.forMeasure = _measure;
	}
	
	if (selected == 0) {
		_vote.vote = [NSNumber numberWithBool:YES];
	}
	else if (selected == 1) {
		_vote.vote = [NSNumber numberWithBool:NO];
	}
	else if (selected == 2) {
		_vote.vote = nil;
	}
	
	if (oldIndexPath != nil)
	{
		UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
		oldCell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	NSError *error;
	if (![[_ballot managedObjectContext] save:&error]) {
		NSLog(@"  DetailedError: %@", [error userInfo]);
		NSLog(@"no!");
		// Handle the error
	}
	
	// update the detailed text, because otherwise it stays the same.
	if (_vote.vote == nil) {
		_selectedCell.detailTextLabel.text = @"Undecided";
	}
	else if ([_vote.vote boolValue] == YES) {
		_selectedCell.detailTextLabel.text = @"YES";
	}
	else {
		_selectedCell.detailTextLabel.text = @"NO";
	}
}

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
	self.ballot = nil;
	self.measure = nil;
	self.vote = nil;
	self.selectedCell = nil;
    [super dealloc];
}


@end
