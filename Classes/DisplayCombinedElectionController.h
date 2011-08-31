//
//  DisplayCombinedElectionController.h
//  Supervote
//
//  Created by augusto callejas on 8/30/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Ballot.h"
#import "DisplayElectionController.h"
#import "Election.h"
#import "ListMeasuresController.h"


@interface DisplayCombinedElectionController : UIViewController {

@private
	Ballot *_ballot;
	Election *election;
	NSManagedObjectContext *_managedObjectContext;
	DisplayElectionController *_controller1;
	ListMeasuresController *_controller2;
}

@property (nonatomic, retain) Election *election;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) DisplayElectionController *controller1;
@property (nonatomic, retain) ListMeasuresController *controller2;

@end
