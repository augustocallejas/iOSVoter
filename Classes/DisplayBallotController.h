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


@interface DisplayBallotController : UITableViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {

@private
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

@property (nonatomic, retain) Election *election;
@property (nonatomic, retain) Ballot *ballot;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController1;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController2;

@end
