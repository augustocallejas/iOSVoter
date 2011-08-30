//
//  FetchedResultsBasedTableViewController.h
//  Supervote
//
//  Created by augusto callejas on 8/29/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//


@interface FetchedResultsBasedTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {

@private
	NSManagedObjectContext *_managedObjectContext;
	NSFetchedResultsController *_fetchedResultsController;
}

- (NSString *)getEntityName;
- (NSArray *)allocSortDescriptors;
- (NSString *)getSectionNameKeyPath;
- (NSString *)getCacheName;
- (NSPredicate *)getPredicate;
- (NSString *)getCellIdentifier;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
