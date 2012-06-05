//
//  SelectDistrictViewController.h
//  Supervote
//
//  Created by augusto callejas on 5/29/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "FetchedResultsBasedTableViewController.h"
#import "District.h"
#import "PotentialDistrictRegistration.h"
#import "SupervoteClient.h"

@interface SelectDistrictViewController : FetchedResultsBasedTableViewController {

}

@property (nonatomic, retain) PotentialDistrictRegistration* registration;
@property (nonatomic, retain) NSIndexPath *selectedRow;
@property (nonatomic, retain) District *choice;
@property (nonatomic, retain) SupervoteClient *client;

@end
