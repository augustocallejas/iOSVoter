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


@implementation VoteMeasureController

@synthesize ballot = _ballot;
@synthesize measure = _measure;
@synthesize vote = _vote;
@synthesize selectedCell = _selectedCell;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
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
			//selectedRow = [vote.forCandidate.displayOrder integerValue];
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
    
	NSString *CellIdentifier = @"VoteMeasureController";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	BOOL selected = NO;
    
    // Configure the cell...
	if (indexPath.row == 0) {
		cell.textLabel.text = @"YES";
		if (_vote != nil && _vote.vote != nil && [_vote.vote boolValue] == YES)
		{
			selected = YES;
		}
	}
	else if (indexPath.row == 1) {
		cell.textLabel.text = @"NO";
		if (_vote != nil && _vote.vote != nil && [_vote.vote boolValue] == NO)
		{
			selected = YES;
		}
	}
	else if (indexPath.row == 2) {
		cell.textLabel.text = @"Undecided";
		if (_vote != nil && _vote.vote == nil)
		{
			selected = YES;
		}
	}
	
	if (selected)
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	/* query for friends' votes on this measure */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	//[request setFetchLimit:2];
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
	NSArray *array = [[self.ballot managedObjectContext] executeFetchRequest:request error:&error];
	if (array != nil)
	{
		NSUInteger count = [array count];
		NSInteger index = 0;
		for (index = 0; index < count; index++)
		{
			FriendMeasureVote *vote = (FriendMeasureVote *) [array objectAtIndex:index];
			if (vote.vote == nil) {
				NSLog(@"%@ votes UNDECIDED", vote.author.name, vote.vote);
			}
			else if ([vote.vote boolValue] == YES) {
				NSLog(@"%@ votes YES", vote.author.name, vote.vote);
			}
			else {
				NSLog(@"%@ votes NO", vote.author.name, vote.vote);

			}
		}
	}
	else
	{
		NSLog(@"no!");
	}
	
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

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
