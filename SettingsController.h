//
//  SettingsController.h
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//


@interface SettingsController : UITableViewController <UITableViewDataSource, UITableViewDelegate, FBSessionDelegate, FBRequestDelegate> {

@private
	Facebook* _facebook;
}

@property(nonatomic, retain) Facebook* facebook;

@end
