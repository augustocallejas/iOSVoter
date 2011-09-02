//
//  VoteMeasureController.h
//  Supervote
//
//  Created by augusto callejas on 9/1/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Ballot.h"
#import "Measure.h"
#import "MeasureVote.h"


@interface VoteMeasureController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {

@private
	Ballot *_ballot;
	Measure *_measure;
	MeasureVote *_vote;
	UITableViewCell *_selectedCell;
}

@property (nonatomic, retain) Ballot *ballot;
@property (nonatomic, retain) Measure *measure;
@property (nonatomic, retain) MeasureVote *vote;
@property (nonatomic, retain) UITableViewCell *selectedCell;

@end
