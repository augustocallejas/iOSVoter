//
//  DisplayElectionController.h
//  Supervote
//
//  Created by augusto callejas on 8/9/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Ballot.h"
#import "Election.h"
#import "FetchedResultsBasedTableViewController.h"


@interface DisplayElectionController : FetchedResultsBasedTableViewController {

@private
	Election *election;
	Ballot *ballot;
}

@property (nonatomic, retain) Election *election;

@end
