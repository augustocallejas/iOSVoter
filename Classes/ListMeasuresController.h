//
//  ListMeasuresController.h
//  Supervote
//
//  Created by augusto callejas on 8/31/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Ballot.h"
#import "Election.h"
#import "FetchedResultsBasedTableViewController.h"


@interface ListMeasuresController : FetchedResultsBasedTableViewController {

@private
	Election *_election;
	Ballot *_ballot;
	UINavigationController* _parentNavController;
}

@property (nonatomic, retain) Election *election;
@property (nonatomic, retain) Ballot *ballot;
@property (nonatomic, retain) UINavigationController *parentNavController;

@end
