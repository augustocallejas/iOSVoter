//
//  SettingsController.h
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//


@interface SettingsController : UITableViewController <UITableViewDataSource, UITableViewDelegate, FBSessionDelegate, FBRequestDelegate> {
	BOOL _loggedIn;
@private
	Facebook *_facebook;
	NSString *_documentsPath;
}

@property(nonatomic, retain) Facebook *facebook;
@property(nonatomic, retain) NSString *documentsPath;

@end
