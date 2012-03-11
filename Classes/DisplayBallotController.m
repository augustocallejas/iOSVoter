//
//  DisplayBallotController.m
//  Supervote
//
//  Created by augusto callejas on 9/1/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "DisplayBallotController.h"

#import <QuartzCore/QuartzCore.h>

#import "BallotItemViewCell.h"
#import "BallotVote.h"
#import "Candidate.h"
#import "EndorsementButton.h"
#import "FacebookFriend.h"
#import "Friend.h"
#import "FriendMeasureVote.h"
#import "Measure.h"
#import "MeasureViewCell.h"
#import "MeasureVote.h"
#import "Position.h"
#import "ViewEndorsementController.h"
#import "VoteCandidateController.h"
#import "VoteMeasureController.h"

@implementation DisplayBallotController

@synthesize election = _election;
@synthesize ballot = _ballot;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController1 = _fetchedResultsController1;
@synthesize fetchedResultsController2 = _fetchedResultsController2;
@synthesize client = _client;

- (void)updateBallot {
	/* TODO: left unimplemented for now */
	//NSDate *newTime = nil;
	//NSDictionary *election = [_client getElection:_election.guid withLastModified:_election.lastModified withNewModifiedTime:&newTime];
}

#pragma mark -
#pragma mark UIButton custom actions

- (IBAction)viewSingleEndorsement:(id)sender{
	EndorsementButton *button = (EndorsementButton *)sender;
	
	if (button.ballotVote != nil || button.measureVote != nil) {
		ViewEndorsementController *controller = [[ViewEndorsementController alloc] initWithNibName:@"ViewEndorsementController" bundle:[NSBundle mainBundle]];
		controller.ballotVote = button.ballotVote;
		controller.measureVote = button.measureVote;
		[[self navigationController] pushViewController:controller animated:YES];
		[controller release];
	}
}

- (IBAction)viewAllEndorsements:(id)sender{
	UIButton *button = (UIButton *)sender;
	
	NSInteger section = button.tag >> 10;
	NSInteger row = button.tag - (section << 10);
	//NSLog(@"Section %d row %d", section, row);
	
	if (section < [self.fetchedResultsController1.sections count]) {	
		Position *position = (Position *) [self.fetchedResultsController1 objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
		
		NSUInteger count = 0;
		NSError *error;
		BallotVote *ballotVote = [VoteCandidateController getBallotVoteForBallot:self.ballot forPosition:position withError:&error andCount:&count];
		
		if (ballotVote != nil) {
			[VoteCandidateController displayEndorsements:ballotVote.forCandidate forPosition:position onNavigationController:self.navigationController];
		}
		else if (error != nil) {
			NSLog(@"Error: %@", [error userInfo]);
		}
		else {
			//		NSLog(@"");
		}
	}
	else {
		section -= [self.fetchedResultsController1.sections count];
		NSUInteger count = 0;
		NSError *error;
		Measure *measure = (Measure *) [self.fetchedResultsController2 objectAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];

		MeasureVote *measureVote = [VoteMeasureController getMeasureVoteForBallot:self.ballot forMeasure:measure withError:&error andCount:&count];
		
		if (measureVote != nil) {
			[VoteMeasureController displayEndorsements:measureVote.vote forMeasure:measure onNavigationController:self.navigationController];
		}
		else if (error != nil) {
			NSLog(@"Error: %@", [error userInfo]);
		}
		else {
			//      NSLog(@"");
		}
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
		viewDidLoadCalled = NO;
	}
	
	return self;
}

- (void)setExpandBarButtonIcon {
	if (socialBallotView) {
		UIImage *userIcon = [UIImage imageNamed:@"1-user.png"];
		[self.navigationItem.rightBarButtonItem setImage:userIcon];
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
		NSLog(@"Did not synchronize correctly");
	}
	
	[self setExpandBarButtonIcon];
	
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
}

#pragma mark -
#pragma mark FetchedResultsBasedTableViewController methods

- (NSFetchedResultsController *)fetchedResultsController1 {
	/* singleton pattern, lazy instantiation */
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
																											 cacheName:nil];
    self.fetchedResultsController1 = theFetchedResultsController;
	self.fetchedResultsController1.delegate = self;
	
	[sort1 release];
	[sort2 release];
    [fetchRequest release];
    [theFetchedResultsController release];
	
    return _fetchedResultsController1;    
}

- (NSFetchedResultsController *)fetchedResultsController2 {
	/* singleton pattern, lazy instantiation */
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
																											 cacheName:nil];
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
		[self configureCellAsPosition:(BallotItemViewCell *) cell atIndexPath:indexPath];
	}
	else {
		[self configureCellAsMeasure:cell atIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section-[self.fetchedResultsController1.sections count])]];
	}
}

- (void)configureCellAsPosition:(BallotItemViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	//NSLog(@"Configure %d %d", [indexPath section], [indexPath row]);
    Position *position = (Position *) [self.fetchedResultsController1 objectAtIndexPath:indexPath];
	cell.majorTitle.text = position.title;
	
	/* http://www.dafont.com/u-s-101.font */
//	cell.majorTitle.font = [UIFont fontWithName:@"U.S. 101" size:18.0];
//	cell.majorTitle.minimumFontSize = 10.0;
//	cell.majorTitle.adjustsFontSizeToFitWidth = YES;
	
//	cell.minorTitle.font = [UIFont fontWithName:@"Calibri" size:5.0];
//	cell.minorTitle.minimumFontSize = 2.0;
//	cell.minorTitle.adjustsFontSizeToFitWidth = YES;

	cell.friendCount.enabled = NO;
	cell.friendCount.tag = (indexPath.section << 10) + indexPath.row;
	
	/* TODO: break this functionality out into a method that VoteCandidate can use, or save references? */
	/* query for a ballot vote, if any */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:2];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"BallotVote" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forBallot == %@ && forPosition == %@", self.ballot, position];
	[request setPredicate:predicate];

	Candidate* candidate = nil;
	NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (array != nil) {
		NSUInteger count = [array count];
		if (count == 0) {
			cell.minorTitle.text = @"<Not selected>";
		}
		else if (count == 1) {
			candidate = ((BallotVote *) [array objectAtIndex:0]).forCandidate;
			if (candidate != nil) {
				cell.minorTitle.text = candidate.name;
				
				NSString *string = [VoteCandidateController getTextForEndorsementButton:position onCandidate:candidate];
				if (string != nil) {
					cell.friendCount.enabled = YES;
					[cell.friendCount setTitle:string forState:UIControlStateNormal];
				}
			}
			else {
				cell.minorTitle.text = @"Undecided";
			}
		}
		else {
			NSLog(@"Should have only one vote!");
		}
	}
	else {
		/* TODO: Handle the error */
		NSLog(@"  DetailedError: %@", [error userInfo]);
	}
		
	[request release];
	
	/* add small black border to all friend icons */
	cell.friendButton1.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendButton1.layer.borderWidth = 1.0f;
	cell.friendButton2.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendButton2.layer.borderWidth = 1.0f;
	cell.friendButton3.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendButton3.layer.borderWidth = 1.0f;
	cell.friendButton4.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendButton4.layer.borderWidth = 1.0f;
	cell.friendButton5.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendButton5.layer.borderWidth = 1.0f;
	
	// if candidate found, then load the endorsements from friends
	if (candidate != nil) {
		error = nil;
		NSArray *friendVotes = [VoteCandidateController getMostRecentFriendEndorsements:5 forPosition:position forCandidate:candidate withError:&error];
		
		if (error == nil) {
			NSUInteger totalCount = [friendVotes count];
			/* TODO: this section is copy and pasted elsewhere, consider evaluating once and accessing from app delegate */
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];
			
			UIImage *genericIcon = [UIImage imageNamed:@"friends.png"];
			
			//		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			//		NSString *documentsDirectory = [paths objectAtIndex:0];
			//		NSString *pathToCandidateIcon = [NSString stringWithFormat:@"%@/images/A000014.jpg", documentsDirectory];
			//		UIImage *candidateIcon = [UIImage imageWithContentsOfFile:pathToCandidateIcon];
			
			//cell.candidateIcon.image = candidateIcon;
			
			/* display the facebook profile photo of the most recent endorsements */
			UIImage *icon;
			if (totalCount > 0) {
				FriendBallotVote *ballotVote = nil;
				ballotVote = (FriendBallotVote *) [friendVotes objectAtIndex:0];
				icon = [DisplayBallotController loadImageForAuthorOfBallotVote:ballotVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
				[cell.friendButton1 setImage:icon forState:UIControlStateNormal];
				cell.friendButton1.ballotVote = ballotVote;
				if (totalCount > 1) {
					ballotVote = (FriendBallotVote *) [friendVotes objectAtIndex:1];
					icon = [DisplayBallotController loadImageForAuthorOfBallotVote:ballotVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
					[cell.friendButton2 setImage:icon forState:UIControlStateNormal];
					cell.friendButton2.ballotVote = ballotVote;
					if (totalCount > 2) {
						ballotVote = (FriendBallotVote *) [friendVotes objectAtIndex:2];
						icon = [DisplayBallotController loadImageForAuthorOfBallotVote:ballotVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
						[cell.friendButton3 setImage:icon forState:UIControlStateNormal];
						cell.friendButton3.ballotVote = ballotVote;
						if (totalCount > 3) {
							ballotVote = (FriendBallotVote *) [friendVotes objectAtIndex:3];
							icon = [DisplayBallotController loadImageForAuthorOfBallotVote:ballotVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
							[cell.friendButton4 setImage:icon forState:UIControlStateNormal];
							cell.friendButton4.ballotVote = ballotVote;
							if (totalCount > 4) {
								ballotVote = (FriendBallotVote *) [friendVotes objectAtIndex:4];
								icon = [DisplayBallotController loadImageForAuthorOfBallotVote:ballotVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
								[cell.friendButton5 setImage:icon forState:UIControlStateNormal];
								cell.friendButton5.ballotVote = ballotVote;
							}
						}
					}
				}
			}
		}
		else {
			NSLog(@"Error: %@", [error userInfo]);
		}

	}
}

+ (UIImage *) loadImageForAuthorOfBallotVote:(FriendBallotVote *)friendVote inDirectory:(NSString *)documentsDirectory orUseIconIfNotPresent:(UIImage *)defaultIcon {
	UIImage *icon = nil;
	if (friendVote.author.facebook != nil && friendVote.author.facebook.photoDownloaded != nil) {
		NSString *path = [NSString stringWithFormat:@"%@/facebook/%@.gif", documentsDirectory, friendVote.author.facebook.friendId];
		icon = [UIImage imageWithContentsOfFile:path];
	}
	
	if (icon == nil) {
		icon = defaultIcon;
	}
	
	return icon;
}

+ (UIImage *) loadImageForAuthorOfMeasureVote:(FriendMeasureVote *)friendVote inDirectory:(NSString *)documentsDirectory orUseIconIfNotPresent:(UIImage *)defaultIcon {
	UIImage *icon = nil;
	if (friendVote.author.facebook != nil && friendVote.author.facebook.photoDownloaded != nil) {
		NSString *path = [NSString stringWithFormat:@"%@/facebook/%@.gif", documentsDirectory, friendVote.author.facebook.friendId];
		icon = [UIImage imageWithContentsOfFile:path];
	}
	
	if (icon == nil) {
		icon = defaultIcon;
	}
	
	return icon;
}

- (void)configureCellAsMeasure:(BallotItemViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Measure *measure = (Measure *) [self.fetchedResultsController2 objectAtIndexPath:indexPath];
	cell.majorTitle.text = [NSString stringWithFormat:@"%@ %@", measure.identifier, measure.title];
	
	/* TODO: break this functionality out into a method that VoteCandidate can use, or save references? */
	/* query for a measure vote, if any */
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setFetchLimit:2];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MeasureVote" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forBallot == %@ && forMeasure == %@", self.ballot, measure];
	[request setPredicate:predicate];
	
	BOOL foundVote = NO;
	NSNumber *vote = nil;
	
	NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (array != nil)
	{
		NSUInteger count = [array count];
		if (count == 0)
		{
			cell.minorTitle.text = @"<Not selected>";
		}
		else if (count == 1)
		{
			foundVote = YES;
			vote = ((MeasureVote *) [array objectAtIndex:0]).vote;
			cell.minorTitle.text = [MeasureViewCell voteToString:vote];
			
			NSString *string = [VoteMeasureController getTextForEndorsementButton:measure onVote:vote];
			if (string != nil) {
				[cell.friendCount setTitle:string forState:UIControlStateNormal];
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
	
	/* add small black border to all friend icons */
	cell.friendButton1.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendButton1.layer.borderWidth = 1.0f;
	cell.friendButton2.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendButton2.layer.borderWidth = 1.0f;
	cell.friendButton3.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendButton3.layer.borderWidth = 1.0f;
	cell.friendButton4.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendButton4.layer.borderWidth = 1.0f;
	cell.friendButton5.layer.borderColor = [UIColor grayColor].CGColor;
	cell.friendButton5.layer.borderWidth = 1.0f;
	
	if (foundVote) {
		error = nil;		
		NSArray *friendVotes = [VoteMeasureController getMostRecentFriendEndorsements:5 forMeasure:measure withVote:vote withError:&error];
		if (error == nil) {
			//		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			//		NSString *documentsDirectory = [paths objectAtIndex:0];
			//		NSString *pathToCandidateIcon = [NSString stringWithFormat:@"%@/images/A000014.jpg", documentsDirectory];
			//		UIImage *candidateIcon = [UIImage imageWithContentsOfFile:pathToCandidateIcon];
			//cell.candidateIcon.image = candidateIcon;
			NSUInteger totalCount = [friendVotes count];
			//NSLog(@"count %d", totalCount);
			
			/* TODO: this section is copy and pasted elsewhere, consider evaluating once and accessing from app delegate */
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];	
			UIImage *genericIcon = [UIImage imageNamed:@"friends.png"];
			
			UIImage *icon;
			if (totalCount > 0) {
				FriendMeasureVote *measureVote = nil;
				measureVote = (FriendMeasureVote *) [friendVotes objectAtIndex:0];
				icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:measureVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
				[cell.friendButton1 setImage:icon forState:UIControlStateNormal];
				cell.friendButton1.measureVote = measureVote;
				if (totalCount > 1) {
					measureVote = (FriendMeasureVote *) [friendVotes objectAtIndex:1];
					icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:measureVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
					[cell.friendButton2 setImage:icon forState:UIControlStateNormal];
					cell.friendButton2.measureVote = measureVote;
					if (totalCount > 2) {
						measureVote = (FriendMeasureVote *) [friendVotes objectAtIndex:2];
						icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:measureVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
						[cell.friendButton3 setImage:icon forState:UIControlStateNormal];
						cell.friendButton3.measureVote = measureVote;
						if (totalCount > 3) {
							measureVote = (FriendMeasureVote *) [friendVotes objectAtIndex:3];
							icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:measureVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
							[cell.friendButton4 setImage:icon forState:UIControlStateNormal];
							cell.friendButton4.measureVote = measureVote;
							if (totalCount > 4) {
								measureVote = (FriendMeasureVote *) [friendVotes objectAtIndex:4];
								icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:measureVote inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
								[cell.friendButton5 setImage:icon forState:UIControlStateNormal];
								cell.friendButton5.measureVote = measureVote;
							}
						}
					}
				}
			}
		}
		else {
			NSLog(@"Error: %@", [error userInfo]);
		}
	}

	cell.friendCount.tag = (([self.fetchedResultsController1.sections count] + indexPath.section) << 10) + indexPath.row;
	
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
	
	//NSLog(@"DisplayBallotController: viewDidLoad");
	viewDidLoadCalled = YES;

	/* TODO: disabling this for now */
//	UIBarButtonItem *reload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateBallot)];
//	self.navigationItem.rightBarButtonItem = reload;
//	[reload release];
	
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(barButtonAction:)];
	self.navigationItem.rightBarButtonItem = barButtonItem;
	[barButtonItem release];
	[self setExpandBarButtonIcon];
	
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
	
	[fetchRequest release];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	NSLog(@"ViewWillApear");
	socialBallotView = [[NSUserDefaults standardUserDefaults] boolForKey:@"SocialBallotMode"];
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
//	[self.tableView reloadData];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	if (!viewDidLoadCalled) {
		//NSLog(@"DisplayBallotController: reloading data in viewDidAppear");
		[self.tableView reloadData];
	}
	else {
		viewDidLoadCalled = NO;
	}
	
	/* reload the table view since the social ballot mode may have been changed in the choose candidate controller */
	socialBallotView = [[NSUserDefaults standardUserDefaults] boolForKey:@"SocialBallotMode"];
	[self setExpandBarButtonIcon];
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
}

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


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
//	if (section < [self.fetchedResultsController1.sections count]) {
//		return [self tableView:tableView titleForPositionHeaderInSection:section];
//	}
//	
//	return [self tableView:tableView titleForMeasureHeaderInSection:section-[self.fetchedResultsController1.sections count]];
//}


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
	} else if (error != nil) {
		NSLog(@"Error: %@", [error userInfo]);
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
	} else if (error != nil) {
		NSLog(@"Error: %@", [error userInfo]);
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
	static NSString *ballotItemIdentifier = @"BallotItemViewCell";
	
	BallotItemViewCell *cell = (BallotItemViewCell *)[tableView dequeueReusableCellWithIdentifier:ballotItemIdentifier];
	if (cell == nil) {
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:ballotItemIdentifier owner:self options:nil];
		
		for (id nibObject in nibObjects) {
			if ([nibObject isKindOfClass:[BallotItemViewCell class]]) {
				cell = (BallotItemViewCell *)nibObject;
				break;
			}
		}
	}
	
	[self configureCell:cell atIndexPath:indexPath];

    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 32.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	/* http://www.iphonedevsdk.com/forum/iphone-sdk-development/5172-font-size-color-tableview-header.html */
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
	
	if (section < [self.fetchedResultsController1.sections count]) {
		label.text = [self tableView:tableView titleForPositionHeaderInSection:section];
	}
	else {
		label.text = [self tableView:tableView titleForMeasureHeaderInSection:section-[self.fetchedResultsController1.sections count]];	
	}

	[customView addSubview:label];
	return customView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section < [self.fetchedResultsController1.sections count]) {
		Position *position = (Position *) [self.fetchedResultsController1 objectAtIndexPath:indexPath];
		
		VoteCandidateController *controller = [[VoteCandidateController alloc] initWithNibName:@"VoteCandidate" bundle:[NSBundle mainBundle]];
		controller.client = _client;
		controller.ballot = self.ballot;
		controller.position = position;
		controller.managedObjectContext = self.managedObjectContext;
		//controller.title = position.level;
		controller.title = @"Candidates";
		
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
	else {
		NSIndexPath *correctIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section-[self.fetchedResultsController1.sections count])];
		Measure *measure = (Measure *) [self.fetchedResultsController2 objectAtIndexPath:correctIndexPath];
		
		VoteMeasureController *controller = [[VoteMeasureController alloc] initWithNibName:@"VoteMeasure" bundle:[NSBundle mainBundle]];
		controller.client = _client;
		controller.ballot = self.ballot;
		controller.measure = measure;
		controller.title = @"Measure";
		//[NSString stringWithFormat:@"Measure %@", measure.identifier];
		
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (socialBallotView == YES) {
        return 88;
    }
	
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
	[super viewDidUnload];
	self.navigationItem.rightBarButtonItem = nil;
	self.fetchedResultsController1.delegate = nil;
	self.fetchedResultsController1 = nil;
	self.fetchedResultsController2.delegate = nil;
	self.fetchedResultsController2 = nil;
}


- (void)dealloc {
	self.election = nil;
	self.ballot = nil;
	self.navigationItem.rightBarButtonItem = nil;
	self.fetchedResultsController1.delegate = nil;
	self.fetchedResultsController1 = nil;
	self.fetchedResultsController2.delegate = nil;
	self.fetchedResultsController2 = nil;
	self.client = nil;
    [super dealloc];
}


@end

