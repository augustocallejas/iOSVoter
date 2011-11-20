//
//  FeedController.h
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//

#import "SupervoteClient.h"

@interface FeedController : UITableViewController {

@private
	NSManagedObjectContext *_managedObjectContext;
	SupervoteClient *client;
}

@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
