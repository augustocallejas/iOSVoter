//
//  SelectGovernmentViewController.h
//  Supervote
//
//  Created by augusto callejas on 6/2/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "FetchedResultsBasedTableViewController.h"
#import "PotentialGovernmentRegistration.h"
#import "SupervoteClient.h"

@interface SelectGovernmentViewController : FetchedResultsBasedTableViewController {

}

@property (nonatomic, retain) PotentialGovernmentRegistration* registration;
@property (nonatomic, retain) SupervoteClient *client;

@end
