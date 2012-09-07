//
//  ListElectionsController.h
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "FacebookClient.h"
#import "PullTableView.h"
#import "PullTableViewController.h"
#import "SupervoteClient.h"

@interface ListElectionsController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, PullTableViewDelegate, ADBannerViewDelegate> {

@private
	BOOL hintDisplayed;
	NSDateFormatter *dateFormatter;
	NSManagedObjectContext *_managedObjectContext;
	NSFetchedResultsController *_fetchedResultsController1;
	NSFetchedResultsController *_fetchedResultsController2;	
}

@property (nonatomic, retain) IBOutlet PullTableView *tableView;
@property (nonatomic, retain) ADBannerView *bannerView;
@property (nonatomic, retain) NSIndexPath *selectedElection;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController1;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController2;
@property (nonatomic, retain) SupervoteClient *client;
@property (nonatomic, retain) FacebookClient *facebookClient;

@end
