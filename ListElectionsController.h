//
//  ListElectionsController.h
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "FacebookClient.h"
#import "FetchedResultsBasedTableViewController.h"
#import "SupervoteClient.h"

@interface ListElectionsController : FetchedResultsBasedTableViewController {

@private
	NSDateFormatter *dateFormatter;
	SupervoteClient *_client;
	FacebookClient *_facebookClient;
}

@property (nonatomic, retain) SupervoteClient *client;
@property (nonatomic, retain) FacebookClient *facebookClient;

- (void)updateElections:(BOOL)withAlerts;

@end
