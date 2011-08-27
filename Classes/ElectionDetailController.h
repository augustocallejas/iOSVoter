//
//  ElectionDetailController.h
//  Supervote
//
//  Created by augusto callejas on 8/9/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//

#import "Election.h"


@interface ElectionDetailController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {

@private
	Election *election;
	NSArray *sortedPositions;
}
- (void)createSortedPositions;

@property (nonatomic, retain) Election *election;

@end
