//
//  VoteCandidateController.m
//  Supervote
//
//  Created by augusto callejas on 8/25/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "VoteCandidateController.h"

#import <QuartzCore/QuartzCore.h>

#import "CandidateViewCell.h"
#import "CreateEndorsementViewController.h"
#import "DisplayBallotController.h"
#import "EndorsementButton.h"
#import "FacebookFriend.h"
#import "Friend.h"
#import "FriendBallotVote.h"
#import "ListEndorsementsController.h"
#import "ViewEndorsementController.h"

@implementation VoteCandidateController

@synthesize ballot;
@synthesize position;

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		Candidate *candidate = (Candidate *) [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:actionSheet.tag inSection:0]];
		[self presentCreateEndorsementViewController:candidate];
	}
	else if (buttonIndex == actionSheet.cancelButtonIndex) {
		/* do nothing */
	}
}

#pragma mark -
#pragma mark UIButton custom actions

- (IBAction)viewSingleEndorsement:(id)sender{
	EndorsementButton *button = (EndorsementButton *)sender;
	
	if (button.ballotVote != nil) {
		ViewEndorsementController *controller = [[ViewEndorsementController alloc] initWithNibName:@"ViewEndorsementController" bundle:[NSBundle mainBundle]];
		controller.ballotVote = button.ballotVote;
		[[self navigationController] pushViewController:controller animated:YES];
		[controller release];
	}
}

- (void)voteOnCandidate:(id)sender{
	Candidate *candidate = (Candidate *) [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:((UIButton *)sender).tag inSection:0]];
	
	if (vote != nil && vote.forCandidate != candidate) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to change your vote?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
		actionSheet.tag = ((UIButton *)sender).tag;
		[actionSheet showFromTabBar:self.tabBarController.tabBar];
		[actionSheet release];
	}
	else {
		[self presentCreateEndorsementViewController:candidate];
	}
}

- (void)presentCreateEndorsementViewController:(Candidate *)candidate{
	CreateEndorsementViewController *controller = [[CreateEndorsementViewController alloc] initWithNibName:@"CreateEndorsementViewController" bundle:[NSBundle mainBundle]];
	controller.delegate = self;
	controller.candidate = candidate;
	/* default value is viewable by friends */
	controller.viewableByFriends = YES;
	controller.isEditOfExisting = NO;
	
	if (vote != nil && vote.forCandidate == candidate) {
		controller.statement = vote.statement;
		controller.viewableByFriends = [vote.viewableByFriends boolValue];
		controller.isEditOfExisting = YES;
	}
	
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (void)didDismissModalView:(BOOL)withVote toCandidate:(Candidate *)candidate orMeasureVote:(NSNumber *)measureVote withOptionalStatement:(NSString *)statement andViewableByFriends:(BOOL)viewable {
	if (withVote) {
		if (vote == nil) {
			vote = [(BallotVote *) [NSEntityDescription insertNewObjectForEntityForName:@"BallotVote" inManagedObjectContext:self.managedObjectContext] retain];
			vote.forBallot = ballot;
			vote.forPosition = position;
		}
		vote.forCandidate = candidate;
		vote.statement = statement;
		vote.viewableByFriends = [NSNumber numberWithBool:viewable];
		
		NSError *error;
		if (![self.managedObjectContext save:&error]) {
			NSLog(@"  DetailedError: %@", [error userInfo]);
			// Handle the error
		}
		
		[self.tableView reloadData];
	}
	else {
		NSLog(@"User canceled their vote selection");
	}
	
//	NSLog(@"Statement: [%@]", statement);

    // Dismiss the modal view controller
    [self dismissModalViewControllerAnimated:YES];
	
}

- (IBAction)viewAllEndorsements:(id)sender{
	UIButton *button = (UIButton *)sender;
	
	Candidate *candidate = (Candidate *) [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
	[VoteCandidateController displayEndorsements:candidate forPosition:self.position onNavigationController:self.navigationController];
}

+ (void)displayEndorsements:(Candidate *)candidate forPosition:(Position *)position onNavigationController:(UINavigationController *)navController {
	ListEndorsementsController *controller = [[ListEndorsementsController alloc] initWithStyle:UITableViewStyleGrouped];
	controller.position = position;
	controller.candidate = candidate;
	controller.title = @"Endorsements";
	controller.managedObjectContext = [candidate managedObjectContext];
	
	[navController pushViewController:controller animated:YES];
	[controller release];
}


#pragma mark -
#pragma mark FetchedResultsBasedTableViewController methods

- (NSString *)getEntityName{
	return @"Candidate";
}

- (NSString *)getSectionNameKeyPath{
	return nil;
}

- (NSString *)getCacheName{
	return @"VoteCandidateController";
}

- (NSArray *)allocSortDescriptors{
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    return [NSArray arrayWithObject:sort];
}

- (NSPredicate *)getPredicate{
	return [NSPredicate predicateWithFormat:@"position == %@", position];
}

- (NSString *)getCellIdentifier{
	return @"VoteCandidateController";
}

+ (NSArray *)getMostRecentFriendEndorsements:(NSInteger)count forPosition:(Position *)position forCandidate:(Candidate *)candidate withError:(NSError **)error {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:count];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FriendBallotVote" inManagedObjectContext:[position managedObjectContext]];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forPosition == %@ && forCandidate == %@", position, candidate];
	[request setPredicate:predicate];
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	NSArray *array = [[position managedObjectContext] executeFetchRequest:request error:error];
	[sort release];
	[request release];
	
	return array;
}

- (void)configureCell:(CandidateViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"Configure %d", indexPath.row);
	Candidate *candidate = (Candidate *) [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.candidateName.text = candidate.name;
	if (candidate.party != nil) {
		cell.partyName.text = candidate.party;
	}
	else if (candidate.occupation != nil) {
		cell.partyName.text = candidate.occupation;
	}
	
	/* add small black border to all friend icons */
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

	/* TODO: this is repeated in other places of the code */
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	UIImage *genericIcon = [UIImage imageNamed:@"users.png"];

	UIImage *icon = nil;
	NSError *error = nil;
	/* TODO: query for 7 */
	NSArray *array = [VoteCandidateController getMostRecentFriendEndorsements:7 forPosition:position forCandidate:candidate withError:&error];
	if (error == nil) {
		NSUInteger count = [array count];
		
		FriendBallotVote *friendVote;
		if (count > 0) {
			friendVote = (FriendBallotVote *) [array objectAtIndex:0];
			icon = [DisplayBallotController loadImageForAuthorOfBallotVote:friendVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
			[cell.friendIcon1 setImage:icon forState:UIControlStateNormal];
			cell.friendIcon1.ballotVote = friendVote;
			
			if (count > 1) {
				friendVote = (FriendBallotVote *) [array objectAtIndex:1];
				icon = [DisplayBallotController loadImageForAuthorOfBallotVote:friendVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
				[cell.friendIcon2 setImage:icon forState:UIControlStateNormal];
				cell.friendIcon2.ballotVote = friendVote;

				if (count > 2) {
					friendVote = (FriendBallotVote *) [array objectAtIndex:2];
					icon = [DisplayBallotController loadImageForAuthorOfBallotVote:friendVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
					[cell.friendIcon3 setImage:icon forState:UIControlStateNormal];
					cell.friendIcon3.ballotVote = friendVote;
					
					if (count > 3) {
						friendVote = (FriendBallotVote *) [array objectAtIndex:3];
						icon = [DisplayBallotController loadImageForAuthorOfBallotVote:friendVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
						[cell.friendIcon4 setImage:icon forState:UIControlStateNormal];
						cell.friendIcon4.ballotVote = friendVote;
						
						if (count > 4) {
							friendVote = (FriendBallotVote *) [array objectAtIndex:4];
							icon = [DisplayBallotController loadImageForAuthorOfBallotVote:friendVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
							[cell.friendIcon5 setImage:icon forState:UIControlStateNormal];
							cell.friendIcon5.ballotVote = friendVote;

							if (count > 5) {
								friendVote = (FriendBallotVote *) [array objectAtIndex:5];
								icon = [DisplayBallotController loadImageForAuthorOfBallotVote:friendVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
								[cell.friendIcon6 setImage:icon forState:UIControlStateNormal];
								cell.friendIcon6.ballotVote = friendVote;
								
								if (count > 6) {
									friendVote = (FriendBallotVote *) [array objectAtIndex:6];
									icon = [DisplayBallotController loadImageForAuthorOfBallotVote:friendVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
									[cell.friendIcon7 setImage:icon forState:UIControlStateNormal];
									cell.friendIcon7.ballotVote = friendVote;
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
	
	NSString *string = [VoteCandidateController getTextForEndorsementButton:position onCandidate:candidate];
	if (string != nil) {
		[cell.viewAllEndorsements setTitle:string forState:UIControlStateNormal];
		
		CGSize stringsize = [string sizeWithFont:[UIFont boldSystemFontOfSize:14]]; 
		[cell.viewAllEndorsements setFrame:CGRectMake(7,45,stringsize.width+10, stringsize.height)];
		
		//cell.viewAllEndorsements.layer.borderColor = [UIColor grayColor].CGColor;
		//cell.viewAllEndorsements.layer.borderWidth = 1.0f;
	}

	if (vote != nil && vote.forCandidate == candidate) {
		/* display the vote status image */
		cell.voteStatus.hidden = NO;
		
		/* hide and disable the "vote" button */
		cell.voteCandidate.enabled = NO;
		cell.voteCandidate.hidden = YES;
		
		/* display privacy level */
		cell.votePrivate.hidden = [vote.viewableByFriends boolValue];

		/* enable the "edit endorsement" button */
		cell.editEndorsement.enabled = YES;
		cell.editEndorsement.hidden = NO;
		[cell.editEndorsement setTitle:@"Edit endorsement" forState:UIControlStateNormal];
	}
	else {
		/* hide the vote status image */
	    cell.voteStatus.hidden = YES;
		
		/* display the "vote" button and enable it */
		[[cell.voteCandidate layer] setCornerRadius:8.0f];
		[[cell.voteCandidate layer] setMasksToBounds:YES];
		[[cell.voteCandidate layer] setBorderWidth:1.0f];
//		[cell.voteCandidate setBackgroundColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.8f alpha:1.0f]];
		cell.voteCandidate.enabled = YES;
		cell.voteCandidate.hidden = NO;
		
		/* display privacy level */
		cell.votePrivate.hidden = YES;
		
		/* disable the "edit endorsement" button */
		cell.editEndorsement.enabled = NO;
		cell.editEndorsement.hidden = YES;
	}
}

+ (NSString *)getTextForEndorsementButton:(Position *)aPosition onCandidate:(Candidate *)aCandidate {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	/* query for friends' votes on this candidate */
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"FriendBallotVote" inManagedObjectContext:[aPosition managedObjectContext]];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forPosition == %@ && forCandidate == %@", aPosition, aCandidate];
	[request setPredicate:predicate];
	
	[request setSortDescriptors:[NSArray arrayWithObjects:nil]];
	
	NSError *error = nil;
	NSUInteger count = [[aPosition managedObjectContext] countForFetchRequest:request error:&error];
	[request release];
	if (error == nil) {
		return [NSString stringWithFormat:@"%d friend%@", count, count==1?@"":@"s"];
	}
	else {
		NSLog(@"NO");
	}
	
	/* don't count users vote */
	//		if (vote != nil && vote.forCandidate == candidate) {
	//			count++;
	//		}
	//		NSUInteger orgCount = 0;
	//		NSString *string = [NSString stringWithFormat:@"%d friend%@, %d organization%@", count, count==1?@"":@"s", orgCount, orgCount==1?@"":@"s"];	
	return nil;
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


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.allowsSelection = NO;
	
	/* query for a ballot vote, if any */
	NSError *error = nil;
	NSUInteger count = 0;
	BallotVote *ballotVote = [VoteCandidateController getBallotVoteForBallot:ballot forPosition:position withError:&error andCount:&count];
	
	if (ballotVote != nil) {
		vote = ballotVote;
	}
	else if (error != nil) {
		NSLog(@"Error: %@", [error userInfo]);
	}
	else {
//		NSLog(@"Unexpected count: %@", count);
	}
}

+ (BallotVote *)getBallotVoteForBallot:(Ballot *)ballot forPosition:(Position *)position withError:(NSError **)error andCount:(NSUInteger *)count{
	/* query for a ballot vote, if any */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:2];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"BallotVote" inManagedObjectContext:[ballot managedObjectContext]];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forBallot == %@ && forPosition == %@", ballot, position];
	[request setPredicate:predicate];
	
	BallotVote *ballotVote = nil;
	NSArray *array = [[ballot managedObjectContext] executeFetchRequest:request error:error];
	if (array != nil)
	{
		*count = [array count];
		if (*count == 0)
		{
		}
		else if (*count == 1)
		{
			ballotVote = [(BallotVote *) [array objectAtIndex:0] retain];
		}
		else
		{
		}
	}
	
	[request release];
	
	return ballotVote;
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
	if (socialBallotView == YES) {
		/* TODO: tweak height for best result */
		return 110;
    }
	
	return 66;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"cellForRow %d", indexPath.row);
    static NSString *identifier = @"CandidateViewCell";
    CandidateViewCell *cell = (CandidateViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
		
		for (id nibObject in nibObjects) {
			if ([nibObject isKindOfClass:[CandidateViewCell class]]) {
				cell = (CandidateViewCell *)nibObject;
				break;
			}
		}
	}
	
	cell.editEndorsement.tag = indexPath.row;
	cell.voteCandidate.tag = indexPath.row;
	cell.viewAllEndorsements.tag = indexPath.row;
	
	[self configureCell:cell atIndexPath:indexPath];
	
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
	if (vote != nil)
	{
		[vote release];
		vote = nil;
	}
}


- (void)dealloc {
	self.ballot = nil;
	self.position = nil;
	if (vote != nil)
	{
		[vote release];
	}
	[super dealloc];
}


@end

