//
//  ViewEndorsementController.m
//  Supervote
//
//  Created by augusto callejas on 11/5/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "ViewEndorsementController.h"

#import "Candidate.h"
#import "Friend.h"

@implementation ViewEndorsementController

@synthesize ballotVote = _ballotVote;
@synthesize friendLabel = _friendLabel;
@synthesize endorsementStatement = _endorsementStatement;
@synthesize candidateName = _candidateName;

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"author %@", _ballotVote.author);
	_friendLabel.text = _ballotVote.author.name;
	_candidateName.text = _ballotVote.forCandidate.name;
	if (_ballotVote.statement == nil) {
	}
	else {
		_endorsementStatement.text = _ballotVote.statement;
	}
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
}


- (void)dealloc {
	self.ballotVote = nil;
    [super dealloc];
}


@end
