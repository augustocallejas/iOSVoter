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
	Ballot *_ballot;
	UINavigationController* parentNavController;
}

@property (nonatomic, retain) Election *election;
@property (nonatomic, retain) Ballot *ballot;
@property (nonatomic, retain) UINavigationController *parentNavController;

@end
