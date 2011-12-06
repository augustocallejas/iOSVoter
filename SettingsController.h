//
//  SettingsController.h
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//

#import "FacebookClient.h"
#import "SupervoteClient.h"


@interface SettingsController : UITableViewController <UITableViewDataSource, UITableViewDelegate, FBSessionDelegate, FBRequestDelegate> {
	
@private
	NSManagedObjectContext *_managedObjectContext;
	NSString *_documentsPath;
	SupervoteClient *client;
	FacebookClient *_facebookClient;
}

@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) SupervoteClient *client;
@property(nonatomic, retain) FacebookClient *facebookClient;
@property(nonatomic, retain) NSString *documentsPath;

- (void)fbDidLogin;
- (void)fbDidLogout;

@end
