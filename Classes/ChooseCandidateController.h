//
//  ChooseCandidateController.h
//  Supervote
//
//  Created by augusto callejas on 8/25/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Ballot.h"
#import "BallotVote.h"
#import "Position.h"


@interface ChooseCandidateController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {

@private
	Ballot *ballot;
	Position *position;
	BallotVote *vote;
	UITableViewCell *selectedCell;
	NSArray *sortedCandidates;
	NSInteger selectedRow;
}
- (void)loadBallotVote;

@property NSInteger selectedRow;
@property (nonatomic, retain) Ballot *ballot;
@property (nonatomic, retain) Position *position;
@property (nonatomic, retain) UITableViewCell *selectedCell;

@end
