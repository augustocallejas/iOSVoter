//
//  ListEndorsementsController.h
//  Supervote
//
//  Created by augusto callejas on 9/28/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Candidate.h"
#import "FetchedResultsBasedTableViewController.h"
#import "Position.h"

@interface ListEndorsementsController : FetchedResultsBasedTableViewController {
	
@private
	Position *_position;
	Candidate *_candidate;
}

@property (nonatomic, retain) Position *position;
@property (nonatomic, retain) Candidate *candidate;

@end
