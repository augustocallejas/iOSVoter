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
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
