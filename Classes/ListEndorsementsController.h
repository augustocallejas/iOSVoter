//
//  ListEndorsementsController.h
//  Supervote
//
//  Created by augusto callejas on 9/28/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Candidate.h"
#import "FetchedResultsBasedTableViewController.h"
#import "Measure.h"
#import "Position.h"

@interface ListEndorsementsController : FetchedResultsBasedTableViewController {
	
@private
	Position *_position;
	Candidate *_candidate;
	
	Measure *_measure;
	NSNumber *_vote;
}

@property (nonatomic, retain) Position *position;
@property (nonatomic, retain) Candidate *candidate;
@property (nonatomic, retain) Measure *measure;
@property (nonatomic, retain) NSNumber *vote;

@end
