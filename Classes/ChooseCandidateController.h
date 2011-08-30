//
//  ChooseCandidateController.h
//  Supervote
//
//  Created by augusto callejas on 8/25/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Ballot.h"
#import "BallotVote.h"
#import "FetchedResultsBasedTableViewController.h"
#import "Position.h"


@interface ChooseCandidateController : FetchedResultsBasedTableViewController {

@private
	Ballot *ballot;
	Position *position;
	BallotVote *vote;
	UITableViewCell *selectedCell;
	NSInteger selectedRow;
}

@property (nonatomic, retain) Ballot *ballot;
@property (nonatomic, retain) Position *position;
@property (nonatomic, retain) UITableViewCell *selectedCell;
@property NSInteger selectedRow;

@end
