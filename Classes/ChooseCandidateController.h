//
//  ChooseCandidateController.h
//  Supervote
//
//  Created by augusto callejas on 8/25/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Position.h"


@interface ChooseCandidateController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {

@private
	Position *position;
	NSArray *sortedCandidates;
	NSInteger selectedRow;
}

@property NSInteger selectedRow;
@property (nonatomic, retain) Position *position;

@end
