//
//  VoterRegistrationViewController.h
//  Supervote
//
//  Created by augusto callejas on 5/20/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "SupervoteClient.h"

#import "PotentialGovernmentRegistration.h"
#import "SelectDistrictViewController.h"
#import "SelectGovernmentViewController.h"

@interface VoterRegistrationViewController : UITableViewController {
}

- (void)selectChoiceFailed:(NSNumber *)status;

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) SupervoteClient *client;
@property (nonatomic, retain) NSArray *registrations;
@property (nonatomic, retain) NSMutableArray *sortedDistrictRegistrations;
@property (nonatomic, retain) SelectDistrictViewController *pushedDistrictController;
@property (nonatomic, retain) SelectGovernmentViewController *pushedController;

@end
