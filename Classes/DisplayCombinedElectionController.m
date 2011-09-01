    //
//  DisplayCombinedElectionController.m
//  Supervote
//
//  Created by augusto callejas on 8/30/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "DisplayCombinedElectionController.h"
#import "DisplayElectionController.h"
#import "Election.h"


@implementation DisplayCombinedElectionController

@synthesize election;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize controller1 = _controller1;
@synthesize controller2 = _controller2;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.controller1 viewWillAppear:animated];
	[self.controller2 viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.controller1 viewDidAppear:animated];
	[self.controller2 viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.controller1 viewDidAppear:animated];
	[self.controller2 viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.controller1 viewDidDisappear:animated];
	[self.controller2 viewDidDisappear:animated];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	/* create a ballot */
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ballot" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchLimit:2];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forElection == %@", election];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedObjects == nil)
	{
		/* TODO: Handle the error */
		NSLog(@"  DetailedError: %@", [error userInfo]);
	}
	else
	{
		if ([fetchedObjects count] == 0)
		{
			// create a ballot for this election
			_ballot = [(Ballot *) [NSEntityDescription insertNewObjectForEntityForName:@"Ballot" inManagedObjectContext:self.managedObjectContext] retain];
			_ballot.forElection = election;
			
			if (![self.managedObjectContext save:&error])
			{
				/* TODO: Handle the error */
				NSLog(@"  DetailedError: %@", [error userInfo]);
			}
		}
		else if ([fetchedObjects count] == 1)
		{
			_ballot = [(Ballot *) [fetchedObjects objectAtIndex:0] retain];
		}
		else {
			NSLog(@"Too many ballots?");
		}
	}
	
	[fetchRequest release];
	
	/* first controller */
	// TODO: unnecessarily creating a new controller on each selection!
	DisplayElectionController *topController = [[DisplayElectionController alloc] initWithNibName:@"DisplayElection" bundle:[NSBundle mainBundle]];
	self.controller1 = topController;	
	self.controller1.election = self.election;
	self.controller1.managedObjectContext = self.managedObjectContext;
	self.controller1.parentNavController = [self navigationController];
	
	self.controller1.view.frame = CGRectZero;
	//self.controller1.view.frame = CGRectMake(0,0,320,230);
	[self.view addSubview:self.controller1.view];

	[topController release];
	
	/* second controller */
	ListMeasuresController *bottomController = [[ListMeasuresController alloc] initWithNibName:@"ListMeasures" bundle:[NSBundle mainBundle]];
	self.controller2 = bottomController;
	self.controller2.election = self.election;
	self.controller2.managedObjectContext = self.managedObjectContext;
	self.controller2.parentNavController = [self navigationController];
		
	// TODO: make 2nd view show up!!!
	self.controller2.view.frame = CGRectZero;
	//CGRectMake(0,self.controller1.view.frame.size.height,320,230);
	[self.view addSubview:self.controller2.view];
	[bottomController release];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self.controller1.view removeFromSuperview];
	self.controller1 = nil;
	
	[self.controller2.view removeFromSuperview];
	self.controller2 = nil;
	
	if (_ballot != nil)
	{
		[_ballot release];
	}
}


- (void)dealloc {
	self.election = nil;
	self.controller1 = nil;
	self.controller2 = nil;
	if (_ballot != nil)
	{
		[_ballot release];
	}
    [super dealloc];
}


@end
