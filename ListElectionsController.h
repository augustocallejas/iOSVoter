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

@interface ListElectionsController : UITableViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {

@private
	NSDateFormatter *dateFormatter;
	SupervoteClient *_client;
	FacebookClient *_facebookClient;
	NSManagedObjectContext *_managedObjectContext;
	NSFetchedResultsController *_fetchedResultsController1;
	NSFetchedResultsController *_fetchedResultsController2;	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController1;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController2;
@property (nonatomic, retain) SupervoteClient *client;
@property (nonatomic, retain) FacebookClient *facebookClient;

- (void)updateElections:(BOOL)withAlerts;

@end
