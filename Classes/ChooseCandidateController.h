//
//  ChooseCandidateController.h
//  Supervote
//
//  Created by augusto callejas on 8/25/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ChooseCandidateController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {

@private
	NSInteger selectedRow;
}

@property NSInteger selectedRow;

@end
