//
//  PullTableViewController.h
//  Supervote
//
//  Created by augusto callejas on 8/19/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "PullTableView.h"

@interface PullTableViewController : UITableViewController <PullTableViewDelegate> {

}

@property (nonatomic, retain) IBOutlet PullTableView *pullTableView;

@end
