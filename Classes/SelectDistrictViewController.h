//
//  SelectDistrictViewController.h
//  Supervote
//
//  Created by augusto callejas on 5/29/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "PotentialDistrictRegistration.h"
#import "SupervoteClient.h"

@interface SelectDistrictViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {

}

@property (nonatomic, retain) PotentialDistrictRegistration* registration;
@property (nonatomic, retain) NSMutableArray *sortedDistricts;
@property (nonatomic, retain) SupervoteClient *client;

@end
