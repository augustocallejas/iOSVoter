//
//  VoteMeasureController.m
//  Supervote
//
//  Created by augusto callejas on 9/1/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "VoteMeasureController.h"

#import <QuartzCore/QuartzCore.h>

#import "DisplayBallotController.h"
#import "Friend.h"
#import "FriendMeasureVote.h"
#import "ListEndorsementsController.h"
#import "MeasureViewCell.h"
#import "ViewEndorsementController.h"

@implementation VoteMeasureController

@synthesize ballot = _ballot;
@synthesize measure = _measure;
@synthesize vote = _vote;
@synthesize client = _client;

//static NSNumber *YES_VOTE = [NSNumber numberWithBool:YES];
//static NSNumber *NO_VOTE = [NSNumber numberWithBool:NO];
//static NSNumber *UNDECIDED_VOTE = nil;

#pragma mark -
#pragma mark UIButton custom actions

- (IBAction)viewSingleEndorsement:(id)sender{
	EndorsementButton *button = (EndorsementButton *)sender;
	
	if (button.measureVote != nil) {
		ViewEndorsementController *controller = [[ViewEndorsementController alloc] initWithNibName:@"ViewEndorsementController" bundle:[NSBundle mainBundle]];
		controller.measureVote = button.measureVote;
		[[self navigationController] pushViewController:controller animated:YES];
		[controller release];
	}
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		/* yes, they want to change their vote */
		NSNumber *voteSelected = nil;
		if (actionSheet.tag == 0) {
			/* YES */
			voteSelected = [NSNumber numberWithBool:YES];
		}
		else if (actionSheet.tag == 1) {
			/* NO */
			voteSelected = [NSNumber numberWithBool:NO];
		}
		else if (actionSheet.tag == 2) {
			/* Undecided */
			voteSelected = nil;
		}
		
		[self presentCreateEndorsementViewController:voteSelected];
	}
	else if (buttonIndex == actionSheet.cancelButtonIndex) {
		/* do nothing */
	}
}

#pragma mark -
#pragma mark Initialization

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
    }
    return self;
}

#pragma mark -
#pragma mark UISegmentedControl action

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

	/* TODO: disabling this for now */
//	UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:nil action:nil];
//	self.navigationItem.rightBarButtonItem = reload;
//	[reload release];
	
	self.tableView.allowsSelection = NO;
	
	/* query for a measure vote, if any */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:2];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MeasureVote" inManagedObjectContext:[self.ballot managedObjectContext]];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forBallot == %@ && forMeasure == %@", self.ballot, self.measure];
	[request setPredicate:predicate];
	
	/* get the vote for this measure */
	NSError *error = nil;
	NSUInteger count = 0;
	MeasureVote *measureVote = [VoteMeasureController getMeasureVoteForBallot:self.ballot forMeasure:self.measure withError:&error andCount:&count];
	if (measureVote != nil) {
		self.vote = measureVote;
	}
	else if (error != nil) {
		NSLog(@"Error: %@", [error userInfo]);
	}
	else {
	}
}

+ (MeasureVote *)getMeasureVoteForBallot:(Ballot *)ballot forMeasure:(Measure *)measure withError:(NSError **)error andCount:(NSUInteger *)count{
	/* query for a measure vote, if any */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:2];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MeasureVote" inManagedObjectContext:[ballot managedObjectContext]];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forBallot == %@ && forMeasure == %@", ballot, measure];
	[request setPredicate:predicate];
	
	MeasureVote *measureVote = nil;
	NSArray *array = [[ballot managedObjectContext] executeFetchRequest:request error:error];
	if (array != nil)
	{
		*count = [array count];
		if (*count == 0)
		{
		}
		else if (*count == 1)
		{
			measureVote = (MeasureVote *) [array objectAtIndex:0];
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
	
	return measureVote;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark UIButton actions

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
	
	if (_vote != nil && !((_vote.vote == nil && voteSelected == nil) ||
						  (_vote.vote != nil && voteSelected != nil && [voteSelected boolValue] == [_vote.vote boolValue]))) {
		/* choosing a different vote */
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to change your vote?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
		actionSheet.tag = button.tag;
		[actionSheet showFromTabBar:self.tabBarController.tabBar];
		[actionSheet release];
	}
	else {
		[self presentCreateEndorsementViewController:voteSelected];
	}


}

- (void)presentCreateEndorsementViewController:(NSNumber *)voteSelected{
	CreateEndorsementViewController *controller = [[CreateEndorsementViewController alloc] initWithNibName:@"CreateEndorsementViewController" bundle:[NSBundle mainBundle]];
	controller.delegate = self;
	controller.measure = _measure;
	controller.measureVote = voteSelected;
	/* default value is viewable by friends */
	controller.viewableByFriends = YES;
	controller.isEditOfExisting = NO;
	if (_vote != nil) {
		/* there is an existing vote */
		if ((_vote.vote == nil && voteSelected == nil) ||
			(_vote.vote != nil && voteSelected != nil && [voteSelected boolValue] == [_vote.vote boolValue]))
		{
			/* editing the same one */
			controller.statement = _vote.statement;
			controller.viewableByFriends = [_vote.viewableByFriends boolValue];
			controller.isEditOfExisting = YES;
		}		
	}

	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (void)didDismissModalView:(BOOL)withVote toCandidate:(Candidate *)candidate orMeasureVote:(NSNumber *)measureVote withOptionalStatement:(NSString *)statement andViewableByFriends:(BOOL)viewable {
	BOOL dismissModalView = YES;
	vote_status status = OK;
	if (withVote) {
		if (_vote == nil) {			
			self.vote = (MeasureVote *) [NSEntityDescription insertNewObjectForEntityForName:@"MeasureVote" inManagedObjectContext:[_ballot managedObjectContext]];
			_vote.forBallot = _ballot;
			_vote.forMeasure = _measure;
		}

		_vote.vote = measureVote;
		_vote.statement = statement;
		_vote.viewableByFriends = [NSNumber numberWithBool:viewable];
		
		status = [_client sendMeasureVote:_vote];
		if (status == OK) {
			/* store vote locally */
			NSError *error = nil;
			if (![[self.ballot managedObjectContext] save:&error]) {
				/* TODO: log to disk */
//				NSLog(@"  DetailedError: %@", [error userInfo]);
			}
			
			[self.tableView reloadData];
		}
		else {
			/* any other status besides OK means we didn't store the vote at the server properly */
			dismissModalView = NO;
		}
	}
	else {
		/* user hit cancel so just dismiss the modal view */
		//NSLog(@"User canceled their vote selection");
		dismissModalView = YES;
	}
	
	if (dismissModalView) {
		// Dismiss the modal view controller
		[self dismissModalViewControllerAnimated:YES];
	}
	else {
		//	OK, HTTP_ERROR, SERVER_ERROR, BAD_REQUEST, ELECTION_CLOSED, UNEXPECTED_RESPONSE
		NSString *title = nil;
		NSString *message = nil;
		switch (status) {
			case HTTP_ERROR:
				title = @"Network Error";
				message = @"Unable to connect to server, please verify your network connection and try again.";
				break;
			case SERVER_ERROR:
				title = @"Server Error";
				message = @"Unable to save vote at the server, please try again in a few minutes.";
				break;
			case BAD_REQUEST:
				title = @"Bad Request";
				message = @"The app sent a bad request to the server.";
				break;
			case ELECTION_CLOSED:
				title = @"Election Closed";
				message = @"This election has closed and cannot receive any new votes.";
				break;
			case UNEXPECTED_RESPONSE:
			default:
				title = @"Unexpected Response";
				message	= @"The server returned an unexpected response.";
				break;
		}
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
														message:message 
													   delegate:nil 
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
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

	[VoteMeasureController displayEndorsements:voteSelected forMeasure:_measure onNavigationController:self.navigationController];
}

+ (void)displayEndorsements:(NSNumber *)aVote forMeasure:(Measure *)aMeasure onNavigationController:(UINavigationController *)navController {
	ListEndorsementsController *controller = [[ListEndorsementsController alloc] initWithStyle:UITableViewStyleGrouped];
	controller.measure = aMeasure;
	controller.vote = aVote;
	controller.title = @"Endorsements";
	controller.managedObjectContext = [aMeasure managedObjectContext];
	
	[navController pushViewController:controller animated:YES];
	[controller release];
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	if (section == 0)
//	{
//		return self.measure.title;
//	}
//	
//	return nil;
//}

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
		/* display the vote status image */
		cell.voteStatus.hidden = NO;

		/* hide and disable the "vote" button */
		cell.voteMeasure.enabled = NO;
		cell.voteMeasure.hidden = YES;
		
		/* display privacy level */
		cell.votePrivate.hidden = [_vote.viewableByFriends boolValue];
		
		/* enable the "edit endorsement" button */
		cell.editEndorsement.enabled = YES;
		cell.editEndorsement.hidden = NO;
		[cell.editEndorsement setTitle:@"Edit endorsement" forState:UIControlStateNormal];
	}
	else {
		/* hide the vote status image */
		cell.voteStatus.hidden = YES;
		
		/* display the "vote" button and enable it */
		[[cell.voteMeasure layer] setCornerRadius:8.0f];
		[[cell.voteMeasure layer] setMasksToBounds:YES];
		[[cell.voteMeasure layer] setBorderWidth:1.0f];
		cell.voteMeasure.enabled = YES;
		cell.voteMeasure.hidden = NO;
		
		/* display privacy level */
		cell.votePrivate.hidden = YES;
		
		/* disable the "edit endorsement" button */
		cell.editEndorsement.enabled = NO;
		cell.editEndorsement.hidden = YES;
	}
	
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
	
	NSString *string = [VoteMeasureController getTextForEndorsementButton:self.measure onVote:currVote];
	if (string != nil) {
		[cell.viewAllEndorsements setTitle:string forState:UIControlStateNormal];
		
		CGSize stringsize = [string sizeWithFont:[UIFont boldSystemFontOfSize:14]]; 
		[cell.viewAllEndorsements setFrame:CGRectMake(12, 45, stringsize.width+10, stringsize.height)];
	}
	
	cell.friendIcon1.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendIcon1.layer.borderWidth = 1.0f;
	cell.friendIcon2.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendIcon2.layer.borderWidth = 1.0f;
	cell.friendIcon3.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendIcon3.layer.borderWidth = 1.0f;
	cell.friendIcon4.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendIcon4.layer.borderWidth = 1.0f;
	cell.friendIcon5.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendIcon5.layer.borderWidth = 1.0f;
	cell.friendIcon6.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendIcon6.layer.borderWidth = 1.0f;
	cell.friendIcon7.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendIcon7.layer.borderWidth = 1.0f;
	
	[cell.friendIcon1 setImage:nil forState:UIControlStateNormal];
	cell.friendIcon1.measureVote = nil;
	[cell.friendIcon2 setImage:nil forState:UIControlStateNormal];
	cell.friendIcon2.measureVote = nil;
	[cell.friendIcon3 setImage:nil forState:UIControlStateNormal];
	cell.friendIcon3.measureVote = nil;
	[cell.friendIcon4 setImage:nil forState:UIControlStateNormal];
	cell.friendIcon4.measureVote = nil;
	[cell.friendIcon5 setImage:nil forState:UIControlStateNormal];
	cell.friendIcon5.measureVote = nil;
	[cell.friendIcon6 setImage:nil forState:UIControlStateNormal];
	cell.friendIcon6.measureVote = nil;
	[cell.friendIcon7 setImage:nil forState:UIControlStateNormal];
	cell.friendIcon7.measureVote = nil;
	
	/* TODO: this is repeated in other places of the code */
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	/* TODO: this code is stand in for now... */
	UIImage *genericIcon = [UIImage imageNamed:@"users.png"];
	
	UIImage *icon = nil;
	NSError *error = nil;
	NSArray *array = [VoteMeasureController getMostRecentFriendEndorsements:7 forMeasure:self.measure withVote:currVote withError:&error];
	if (error == nil) {
		FriendMeasureVote *friendVote;
		NSUInteger count = [array count];		
		if (count > 0) {
			friendVote = (FriendMeasureVote *) [array objectAtIndex:0];
			icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:friendVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
			[cell.friendIcon1 setImage:icon forState:UIControlStateNormal];
			cell.friendIcon1.measureVote = friendVote;
			if (count > 1) {
				friendVote = (FriendMeasureVote *) [array objectAtIndex:1];
				icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:friendVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
				[cell.friendIcon2 setImage:icon forState:UIControlStateNormal];
				cell.friendIcon2.measureVote = friendVote;
				if (count > 2) {
					friendVote = (FriendMeasureVote *) [array objectAtIndex:2];
					icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:friendVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
					[cell.friendIcon3 setImage:icon forState:UIControlStateNormal];
					cell.friendIcon3.measureVote = friendVote;
					if (count > 3) {
						friendVote = (FriendMeasureVote *) [array objectAtIndex:3];
						icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:friendVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
						[cell.friendIcon4 setImage:icon forState:UIControlStateNormal];
						cell.friendIcon4.measureVote = friendVote;
						if (count > 4) {
							friendVote = (FriendMeasureVote *) [array objectAtIndex:4];
							icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:friendVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
							[cell.friendIcon5 setImage:icon forState:UIControlStateNormal];
							cell.friendIcon5.measureVote = friendVote;
							if (count > 5) {
								friendVote = (FriendMeasureVote *) [array objectAtIndex:5];
								icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:friendVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
								[cell.friendIcon6 setImage:icon forState:UIControlStateNormal];
								cell.friendIcon6.measureVote = friendVote;
								if (count > 6) {
									friendVote = (FriendMeasureVote *) [array objectAtIndex:6];
									icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:friendVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
									[cell.friendIcon7 setImage:icon forState:UIControlStateNormal];
									cell.friendIcon7.measureVote = friendVote;
								}
							}
						}
					}
				}
			}
		}
	}
	else {
		NSLog(@"Error: %@", [error userInfo]);
	}
	
    return cell;
}

+ (NSArray *)getMostRecentFriendEndorsements:(NSInteger)count forMeasure:(Measure *)measure withVote:(NSNumber *)vote withError:(NSError **)error {
	/* query for friends' votes on this measure */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FriendMeasureVote" inManagedObjectContext:[measure managedObjectContext]];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forMeasure == %@ && vote == %@", measure, vote];
	[request setPredicate:predicate];

	/* TODO: sort by descending date */
	
	/* fill in the top endorsements */
	[request setFetchLimit:3];
	
	NSArray *array = [[measure managedObjectContext] executeFetchRequest:request error:error];
	[request release];
	
	return array;
}


+ (NSString *)getTextForEndorsementButton:(Measure *)aMeasure onVote:(NSNumber *)aVote {
	/* query for friends' votes on this measure */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FriendMeasureVote" inManagedObjectContext:[aMeasure managedObjectContext]];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forMeasure == %@ && vote == %@", aMeasure, aVote];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSUInteger count = [[aMeasure managedObjectContext] countForFetchRequest:request error:&error];
	[request release];
	if (error == nil) {
		//		NSUInteger orgCount = 0;
		//		NSString *string = [NSString stringWithFormat:@"%d friend%@, %d organization%@", count, count==1?@"":@"s", orgCount, orgCount==1?@"":@"s"];
		NSString *string = [NSString stringWithFormat:@"%d friend%@", count, count==1?@"":@"s"];
		return string;
	}
	else {
		NSLog(@"Error: %@", [error userInfo]);
	}
	
	return nil;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section != 0) {
		return 0.0;
	}
	
	return 32.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section != 0) {
		return nil;
	}
	
	UIFont *font = [UIFont fontWithName:@"LeagueGothic" size:22.0];
	
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 32.0)] autorelease];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.opaque = NO;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor darkGrayColor];
	label.font = font;
	label.adjustsFontSizeToFitWidth = YES;
	label.minimumFontSize = 18.0;
	label.frame = CGRectMake(10.0, 0.0, 290.0, 32.0);
	label.text = self.measure.title;
	
	[customView addSubview:label];
	return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (socialBallotView == YES) {
        return 110;
    }
	
	return 66;
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
	self.navigationItem.rightBarButtonItem = nil;
}


- (void)dealloc {
	self.client = nil;
	self.ballot = nil;
	self.measure = nil;
	self.vote = nil;
    [super dealloc];
}


@end
