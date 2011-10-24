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
#import "FacebookFriend.h"
#import "Friend.h"
#import "Measure.h"
#import "MeasureViewCell.h"
#import "MeasureVote.h"
#import "Position.h"
#import "VoteCandidateController.h"
#import "VoteMeasureController.h"

@implementation DisplayBallotController

@synthesize election = _election;
@synthesize ballot = _ballot;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController1 = _fetchedResultsController1;
@synthesize fetchedResultsController2 = _fetchedResultsController2;

#pragma mark -
#pragma mark UIButton custom actions

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
		segControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Compact", @"Expanded", nil]];
		segControl.segmentedControlStyle = UISegmentedControlStyleBar;
		segControl.selectedSegmentIndex = socialBallotView ? 1 : 0;
		[segControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
		self.navigationItem.titleView = segControl;
		//[control release];
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

- (void)animationStopped:(id)sender {
	//NSLog(@"animation");
}

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
			
			UIImage *genericIcon = [UIImage imageNamed:@"users.png"];
			
			//		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			//		NSString *documentsDirectory = [paths objectAtIndex:0];
			//		NSString *pathToCandidateIcon = [NSString stringWithFormat:@"%@/images/A000014.jpg", documentsDirectory];
			//		UIImage *candidateIcon = [UIImage imageWithContentsOfFile:pathToCandidateIcon];
			
			//cell.candidateIcon.image = candidateIcon;
			
			/* display the facebook profile photo of the most recent endorsements */
			UIImage *icon;
			if (totalCount > 0) {	
				icon = [DisplayBallotController loadImageForAuthorOfBallotVote:[friendVotes objectAtIndex:0] inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
				[cell.friendButton1 setImage:icon forState:UIControlStateNormal];
				if (totalCount > 1) {
					icon = [DisplayBallotController loadImageForAuthorOfBallotVote:[friendVotes objectAtIndex:1] inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
					[cell.friendButton2 setImage:icon forState:UIControlStateNormal];
					if (totalCount > 2) {	
						icon = [DisplayBallotController loadImageForAuthorOfBallotVote:[friendVotes objectAtIndex:2] inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
						[cell.friendButton3 setImage:icon forState:UIControlStateNormal];
						if (totalCount > 3) {
							icon = [DisplayBallotController loadImageForAuthorOfBallotVote:[friendVotes objectAtIndex:3] inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
							[cell.friendButton4 setImage:icon forState:UIControlStateNormal];
							if (totalCount > 4) {
								icon = [DisplayBallotController loadImageForAuthorOfBallotVote:[friendVotes objectAtIndex:4] inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
								[cell.friendButton5 setImage:icon forState:UIControlStateNormal];
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
	cell.majorTitle.text = measure.title;
	
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
			NSLog(@"count %d", totalCount);
			
			/* TODO: this section is copy and pasted elsewhere, consider evaluating once and accessing from app delegate */
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *documentsDirectory = [paths objectAtIndex:0];	
			UIImage *genericIcon = [UIImage imageNamed:@"users.png"];
			
			UIImage *icon;
			if (totalCount > 0) {
				icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:[friendVotes objectAtIndex:0] inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
				[cell.friendButton1 setImage:icon forState:UIControlStateNormal];
				if (totalCount > 1) {
					icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:[friendVotes objectAtIndex:1] inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
					[cell.friendButton2 setImage:icon forState:UIControlStateNormal];
					if (totalCount > 2) {
						icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:[friendVotes objectAtIndex:2] inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
						[cell.friendButton3 setImage:icon forState:UIControlStateNormal];
						if (totalCount > 3) {
							icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:[friendVotes objectAtIndex:3] inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
							[cell.friendButton4 setImage:icon forState:UIControlStateNormal];
							if (totalCount > 4) {
								icon = [DisplayBallotController loadImageForAuthorOfMeasureVote:[friendVotes objectAtIndex:4] inDirectory:documentsDirectory orUseIconIfNotPresent:genericIcon];
								[cell.friendButton5 setImage:icon forState:UIControlStateNormal];
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
	NSLog(@"DisplayBallotController: viewDidLoad");
	viewDidLoadCalled = YES;
	
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
	/* reload the table view since the social ballot mode may have been changed in the choose candidate controller */
	socialBallotView = [[NSUserDefaults standardUserDefaults] boolForKey:@"SocialBallotMode"];
	segControl.selectedSegmentIndex = socialBallotView ? 1 : 0;
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
	if (!viewDidLoadCalled) {
		NSLog(@"DisplayBallotController: reloading data in viewDidAppear");
		[self.tableView reloadData];
	}
	else {
		viewDidLoadCalled = NO;
	}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section < [self.fetchedResultsController1.sections count]) {
		Position *position = (Position *) [self.fetchedResultsController1 objectAtIndexPath:indexPath];
		
		VoteCandidateController *controller = [[VoteCandidateController alloc] initWithNibName:@"VoteCandidate" bundle:[NSBundle mainBundle]];
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
	[super viewDidLoad];
	self.fetchedResultsController1.delegate = nil;
	self.fetchedResultsController1 = nil;
	self.fetchedResultsController2.delegate = nil;
	self.fetchedResultsController2 = nil;
}


- (void)dealloc {
	if (segControl != nil) {
		[segControl release];
	}
	self.election = nil;
	self.ballot = nil;
	self.fetchedResultsController1.delegate = nil;
	self.fetchedResultsController1 = nil;
	self.fetchedResultsController2.delegate = nil;
	self.fetchedResultsController2 = nil;
    [super dealloc];
}


@end

