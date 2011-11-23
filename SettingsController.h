//
//  SettingsController.h
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//

#import "SupervoteClient.h"

@interface SettingsController : UITableViewController <UITableViewDataSource, UITableViewDelegate, FBSessionDelegate, FBRequestDelegate> {
	BOOL _loggedIn;
@private
	NSManagedObjectContext *_managedObjectContext;
	Facebook *_facebook;
	NSString *_documentsPath;
	SupervoteClient *client;
}

@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) Facebook *facebook;
@property(nonatomic, retain) NSString *documentsPath;

@end
