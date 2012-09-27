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
#import "PoliticalParty.h"
#import "PositionToCandidate.h"
#import "SupervoteAppDelegate.h"
#import "ViewEndorsementController.h"

@implementation VoteCandidateController

@synthesize pullTableView;
@synthesize ballot;
@synthesize position;
@synthesize client = _client;
@synthesize changeVoteSheet;
@synthesize deleteVoteSheet;

# pragma mark -
# pragma mark PullTableViewDelegate methods

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:0.0f];
}

- (void) refreshTable
{
	SupervoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate updateData:YES];
	
    self.pullTableView.pullLastRefreshDate = appDelegate.lastRefreshDate;
    self.pullTableView.pullTableIsRefreshing = NO;
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (changeVoteSheet == actionSheet) {
		changeVoteSheet = nil;
		if (buttonIndex == actionSheet.destructiveButtonIndex) {
			PositionToCandidate *p2c = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:actionSheet.tag inSection:0]];
			[self presentCreateEndorsementViewController:p2c.candidate];
		}
		else if (buttonIndex == actionSheet.cancelButtonIndex) {
			/* do nothing */
		}
	}
	else if (deleteVoteSheet == actionSheet) {
		deleteVoteSheet = nil;
		if (buttonIndex == actionSheet.destructiveButtonIndex) {
			[self performDeleteVote];
		}
		else if (buttonIndex == actionSheet.cancelButtonIndex) {
			/* do nothing */
		}
	}
}

- (void)performDeleteVote {
	if (vote != nil) {
		vote_status status = [[self client] deleteBallotVote:vote];
		if (status == OK) {
			NSError *error = nil;
			[self.managedObjectContext deleteObject:vote];
			[self.managedObjectContext save:&error];
			[vote release];
			vote = nil;
			
			[self.tableView reloadData];
		}
		else {
			/* TODO: this code is a direct copy from VoteMeasureController */
			//	OK, HTTP_ERROR, SERVER_ERROR, BAD_REQUEST, ELECTION_CLOSED, UNEXPECTED_RESPONSE
			NSString *title = nil;
			NSString *message = nil;
			switch (status) {
				case HTTP_ERROR:
					title = NSLocalizedString(@"HttpErrorTitle", nil);
					message = NSLocalizedString(@"HttpErrorMessage", nil);
					break;
				case SERVER_ERROR:
					title = NSLocalizedString(@"ServerErrorTitle", nil);
					message = NSLocalizedString(@"SaveVoteServerErrorMessage", nil);
					break;
				case BAD_REQUEST:
					title = NSLocalizedString(@"BadRequestTitle", nil);
					message = NSLocalizedString(@"BadRequestMessage", nil);
					break;
				case UNEXPECTED_RESPONSE:
				default:
					title = NSLocalizedString(@"UnexpectedResponseTitle", nil);
					message	= NSLocalizedString(@"UnexpectedResponseMessage", nil);
					break;
			}
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
															message:message 
														   delegate:nil 
												  cancelButtonTitle:NSLocalizedString(@"OK", nil)
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

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
	PositionToCandidate *p2c = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:((UIButton *)sender).tag inSection:0]];
	
	if (vote != nil && vote.forCandidate != p2c.candidate) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ChangeVoteWarning", nil)
																 delegate:self
														cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
												   destructiveButtonTitle:NSLocalizedString(@"YES", nil)
														otherButtonTitles:nil];
		actionSheet.tag = ((UIButton *)sender).tag;
		changeVoteSheet = actionSheet;
		[actionSheet showFromTabBar:self.tabBarController.tabBar];
		[actionSheet release];
	}
	else {
		[self presentCreateEndorsementViewController:p2c.candidate];
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

- (UIView *)didDismissModalView:(BOOL)withVote toCandidate:(Candidate *)candidate orMeasureVote:(NSNumber *)measureVote withOptionalStatement:(NSString *)statement andViewableByFriends:(BOOL)viewable {
	UIView *myView = nil;
	BOOL dismissModalView = YES;
	vote_status status = OK;
	if (withVote) {
#if USE_TESTFLIGHT
		[TestFlight passCheckpoint:@"EndorsedCandidate"];
#endif
		
		if (vote == nil) {
			vote = [(BallotVote *) [NSEntityDescription insertNewObjectForEntityForName:@"BallotVote" inManagedObjectContext:self.managedObjectContext] retain];
			vote.forBallot = ballot;
			vote.forPosition = position;
		}
		
		vote.forCandidate = candidate;
		vote.statement = statement;
		vote.viewableByFriends = [NSNumber numberWithBool:viewable];
		
		status = [_client sendBallotVote:vote];
		if (status == OK) {
			/* store vote locally */
			NSError *error = nil;
			if (![self.managedObjectContext save:&error]) {
				LogError(@"Error while saving managed object: %@", [error userInfo]);
			}
			else {
				LogInfo(@"Endorsement created for candidate '%@' on position '%@'", candidate.guid, position.guid);
			}
			
			myView = self.view;
			[self.tableView reloadData];
		}
		else {
			/* any other status besides OK means we didn't store the vote at the server properly */
			dismissModalView = NO;
		}
	}
	else {
		/* user hit cancel so just dismiss the modal view */
		LogInfo(@"User canceled their vote selection");
		dismissModalView = YES;
	}
	
	if (dismissModalView) {
		// Dismiss the modal view controller
		[self dismissModalViewControllerAnimated:YES];
	}
	else {
		/* TODO: this code is a direct copy from VoteMeasureController */
		//	OK, HTTP_ERROR, SERVER_ERROR, BAD_REQUEST, ELECTION_CLOSED, UNEXPECTED_RESPONSE
		NSString *title = nil;
		NSString *message = nil;
		switch (status) {
			case HTTP_ERROR:
				title = NSLocalizedString(@"HttpErrorTitle", nil);
				message = NSLocalizedString(@"HttpErrorMessage", nil);
				break;
			case SERVER_ERROR:
				title = NSLocalizedString(@"ServerErrorTitle", nil);
				message = NSLocalizedString(@"SaveVoteServerErrorMessage", nil);
				break;
			case BAD_REQUEST:
				title = NSLocalizedString(@"BadRequestTitle", nil);
				message = NSLocalizedString(@"BadRequestMessage", nil);
				break;
			case ELECTION_CLOSED:
				title = NSLocalizedString(@"ElectionClosedTitle", nil);
				message = NSLocalizedString(@"ElectionClosedMessage", nil);
				break;
			case UNEXPECTED_RESPONSE:
			default:
				title = NSLocalizedString(@"UnexpectedResponseTitle", nil);
				message	= NSLocalizedString(@"UnexpectedResponseMessage", nil);
				break;
		}
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
														message:message 
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	return myView;
}

- (IBAction)viewAllEndorsements:(id)sender{
	UIButton *button = (UIButton *)sender;
	
	PositionToCandidate *p2c = (PositionToCandidate *) [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
	[VoteCandidateController displayEndorsements:p2c.candidate forPosition:self.position onNavigationController:self.navigationController];
}

+ (void)displayEndorsements:(Candidate *)candidate forPosition:(Position *)position onNavigationController:(UINavigationController *)navController {
	ListEndorsementsController *controller = [[ListEndorsementsController alloc] initWithStyle:UITableViewStyleGrouped];
	controller.position = position;
	controller.candidate = candidate;
	controller.title = NSLocalizedString(@"ListEndorsementsTitle", nil);
	controller.managedObjectContext = [candidate managedObjectContext];
	
	[navController pushViewController:controller animated:YES];
	[controller release];
}


#pragma mark -
#pragma mark FetchedResultsBasedTableViewController methods

- (NSString *)getEntityName{
	return @"PositionToCandidate";
}

- (NSString *)getSectionNameKeyPath{
	return nil;
}

- (NSString *)getCacheName{
	return nil;
//	return @"VoteCandidateController";
}

- (NSArray *)getSortDescriptors{
	NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES] autorelease];
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

- (void)longPressHandle:(UILongPressGestureRecognizer *)longRecogizer {
	if (longRecogizer.state == UIGestureRecognizerStateBegan) {		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"DeleteVoteWarning", nil)
																 delegate:self
														cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
												   destructiveButtonTitle:NSLocalizedString(@"YES", nil)
														otherButtonTitles:nil];
		actionSheet.tag = longRecogizer.view.tag;
		deleteVoteSheet = actionSheet;
		[actionSheet showFromTabBar:self.tabBarController.tabBar];
		[actionSheet release];
	}
}

- (void)configureCell:(CandidateViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	PositionToCandidate *p2c = [self.fetchedResultsController objectAtIndexPath:indexPath];
	Candidate *candidate = p2c.candidate;
	
	cell.candidateName.text = candidate.name;
	/* political party takes priority over subtitle attribute */
	if (candidate.party != nil) {
		cell.partyName.text = candidate.party.name;
	}
	else if (candidate.subtitle != nil) {
		cell.partyName.text = candidate.subtitle;
	}
	else {
		cell.partyName.text = @"";
	}

	
	[cell.voteCandidate setTitle:NSLocalizedString(@"Vote", nil) forState:UIControlStateNormal];
	
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
	
	UIImage *genericIcon = [UIImage imageNamed:@"user.png"];

	[cell.friendIcon1 setImage:nil forState:UIControlStateNormal];
	cell.friendIcon1.ballotVote = nil;
	[cell.friendIcon2 setImage:nil forState:UIControlStateNormal];
	cell.friendIcon2.ballotVote = nil;
	[cell.friendIcon3 setImage:nil forState:UIControlStateNormal];
	cell.friendIcon3.ballotVote = nil;
	[cell.friendIcon4 setImage:nil forState:UIControlStateNormal];
	cell.friendIcon4.ballotVote = nil;
	[cell.friendIcon5 setImage:nil forState:UIControlStateNormal];
	cell.friendIcon5.ballotVote = nil;
	[cell.friendIcon6 setImage:nil forState:UIControlStateNormal];
	cell.friendIcon6.ballotVote = nil;
	[cell.friendIcon7 setImage:nil forState:UIControlStateNormal];
	cell.friendIcon7.ballotVote = nil;
	
	UIImage *icon = nil;
	NSError *error = nil;
	/* TODO: query for 7 */
	NSArray *array = [VoteCandidateController getMostRecentFriendEndorsements:7 forPosition:position forCandidate:candidate withError:&error];
	if (error == nil) {
		NSUInteger count = [array count];
		LogDebug(@"Candidate %@ has %d friend vote(s)", candidate.name, count);
		
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
		LogError(@"Error while getting most recent friend endorsements: %@", [error userInfo]);
	}
	
	NSString *string = [VoteCandidateController getTextForEndorsementButton:position onCandidate:candidate];
	if (string != nil) {
		[cell.viewAllEndorsements setTitle:string forState:UIControlStateNormal];
		
		CGSize stringsize = [string sizeWithFont:[UIFont boldSystemFontOfSize:14]]; 
		[cell.viewAllEndorsements setFrame:CGRectMake(7,45,stringsize.width+10, stringsize.height)];
		
		//cell.viewAllEndorsements.layer.borderColor = [UIColor grayColor].CGColor;
		//cell.viewAllEndorsements.layer.borderWidth = 1.0f;
	}

//	/* TODO: shouldn't this be in the CandidateViewCell? */
//	cell.deleteCandidate.hidden = YES;
//	[[cell.deleteCandidate layer] setCornerRadius:8.0f];
//	[[cell.deleteCandidate layer] setMasksToBounds:YES];
//	[[cell.deleteCandidate layer] setBorderWidth:1.0f];

	if (vote != nil && vote.forCandidate == candidate) {
		if ([cell.gestureRecognizers count] == 0) {
			UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc]
															initWithTarget:self action:@selector(longPressHandle:)];
			
			[longRecognizer setNumberOfTouchesRequired:1];
			longRecognizer.minimumPressDuration = 1.0;
			[cell addGestureRecognizer:longRecognizer];
			[longRecognizer release];
		}
		[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
		
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
		[cell.editEndorsement setTitle:NSLocalizedString(@"EditEndorsement", nil) forState:UIControlStateNormal];
	}
	else {
		if ([cell.gestureRecognizers count] == 1) {
			[cell removeGestureRecognizer:[cell.gestureRecognizers objectAtIndex:0]];
		}
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		
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
//		return [NSString stringWithFormat:@"%d friend%@", count, count==1?@"":@"s"];
		return [NSString stringWithFormat:@"%d %@", count, NSLocalizedString(count==1?@"Friend":@"Friends", nil)];
	}
	else {
		LogError(@"Error while fetching friend count for ballot: %@", [error localizedDescription]);
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
		// Custom initialization.
	}
	
	return self;
}

- (void)setExpandBarButtonIcon {
	if (socialBallotView) {
		UIImage *userIcon = [UIImage imageNamed:@"1-user.png"];
		[self.navigationItem.rightBarButtonItem  setImage:userIcon];
	}
	else {
		UIImage *groupIcon = [UIImage imageNamed:@"2-user.png"];
		[self.navigationItem.rightBarButtonItem setImage:groupIcon];
	}
}

#pragma mark -
#pragma mark UIBarButtonItem action

- (void)barButtonAction:(id)sender {	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	socialBallotView = !socialBallotView;
	[prefs setBool:socialBallotView forKey:@"SocialBallotMode"];
	if (![prefs synchronize]) {
		LogError(@"Unable to synchronize preferences");
	}
	
	[self setExpandBarButtonIcon];
	
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	/* TODO: copied from ListElectionsController */
	self.pullTableView.pullArrowImage = [UIImage imageNamed:@"blackArrow"];
    self.pullTableView.pullBackgroundColor = [UIColor lightTextColor];
    self.pullTableView.pullTextColor = [UIColor blackColor];
	
	SupervoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	self.pullTableView.pullLastRefreshDate = appDelegate.lastRefreshDate;
	
	[[NSNotificationCenter defaultCenter] addObserver:self.tableView
                                             selector:@selector(reloadData)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
	
	/* http://stackoverflow.com/questions/599405/iphone-navigation-bar-title-text-color */
	UIFont *font = [UIFont fontWithName:@"LeagueGothic" size:30.0];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	label.font = font;
	//label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor whiteColor];
	label.text = self.title;
	[label sizeToFit];
	self.navigationItem.titleView = label;
	[label release];
	
	/* TODO: disabling this for now */
//	UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:nil action:nil];
//	self.navigationItem.rightBarButtonItem = reload;
//	[reload release];
	
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(barButtonAction:)];
	self.navigationItem.rightBarButtonItem = barButtonItem;
	[barButtonItem release];
	[self setExpandBarButtonIcon];
	
	/* query for a ballot vote, if any */
	NSError *error = nil;
	NSUInteger count = 0;
	BallotVote *ballotVote = [VoteCandidateController getBallotVoteForBallot:ballot forPosition:position withError:&error andCount:&count];
	
	if (ballotVote != nil) {
		vote = [ballotVote retain];
	}
	else if (error != nil) {
		LogError(@"Error while fetching ballot vote: %@", [error localizedDescription]);
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
			ballotVote = (BallotVote *) [array objectAtIndex:0];
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

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//	if (section == 0)
//	{
//		return position.title;
//	}
//	
//	return nil;
//}

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
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

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
	label.text = position.title;
	
	[customView addSubview:label];
	[label release];
	return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (socialBallotView == YES) {
		/* TODO: tweak height for best result */
		return 110;
    }
	
	return 66;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
	
	cell.tag = indexPath.row;
	cell.editEndorsement.tag = indexPath.row;
	cell.voteCandidate.tag = indexPath.row;
//	cell.deleteCandidate.tag = indexPath.row;
	cell.viewAllEndorsements.tag = indexPath.row;
	cell.voteStatus.tag = indexPath.row;
	
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
	[[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
	self.navigationItem.titleView = nil;
	self.navigationItem.rightBarButtonItem = nil;
	if (vote != nil) {
		[vote release];
		vote = nil;
	}
	[super viewDidUnload];
}


- (void)dealloc {
	self.pullTableView = nil;
	self.client = nil;
	self.ballot = nil;
	self.position = nil;
	if (vote != nil)
	{
		[vote release];
	}
	[super dealloc];
}


@end

