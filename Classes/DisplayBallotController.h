//
//  DisplayBallotController.h
//  Supervote
//
//  Created by augusto callejas on 9/1/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Ballot.h"
#import "Election.h"
#import "BallotItemViewCell.h"
#import "FriendBallotVote.h"
#import "FriendMeasureVote.h"

@interface DisplayBallotController : UITableViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {

@private
	BOOL viewDidLoadCalled;
	UISegmentedControl* segControl;
	BOOL socialBallotView;
	Election *_election;
	Ballot *_ballot;
	NSManagedObjectContext *_managedObjectContext;
	NSFetchedResultsController *_fetchedResultsController1;
	NSFetchedResultsController *_fetchedResultsController2;
}

- (void)segmentAction:(id)sender;
- (NSString *)tableView:(UITableView *)tableView titleForPositionHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForMeasureHeaderInSection:(NSInteger)section;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureCellAsPosition:(BallotItemViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureCellAsMeasure:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (IBAction)viewAllEndorsements:(id)sender;
+ (UIImage *) loadImageForAuthorOfBallotVote:(FriendBallotVote *)friendVote inDirectory:(NSString *)documentsDirectory orUseIconIfNotPresent:(UIImage *)defaultIcon;
+ (UIImage *) loadImageForAuthorOfMeasureVote:(FriendMeasureVote *)friendVote inDirectory:(NSString *)documentsDirectory orUseIconIfNotPresent:(UIImage *)defaultIcon;
	
@property (nonatomic, retain) Election *election;
@property (nonatomic, retain) Ballot *ballot;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController1;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController2;

@end
