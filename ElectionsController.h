//
//  ElectionsController.h
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//


@interface ElectionsController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
	
@private
	NSManagedObjectContext *managedObjectContext;
	NSArray *elections;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *elections;

@end
