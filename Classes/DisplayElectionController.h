//
//  DisplayElectionController.h
//  Supervote
//
//  Created by augusto callejas on 8/9/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Ballot.h"
#import "Election.h"


@interface DisplayElectionController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {

@private
	Election *election;
	Ballot *ballot;
	NSArray *sortedPositions;
}
- (void)createSortedPositionsAndBallot;

@property (nonatomic, retain) Election *election;

@end
