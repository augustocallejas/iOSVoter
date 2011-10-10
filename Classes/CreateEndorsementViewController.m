//
//  CreateEndorsementViewController.m
//  Supervote
//
//  Created by augusto callejas on 9/29/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "CreateEndorsementViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation CreateEndorsementViewController

@synthesize candidate = _candidate;
@synthesize measure = _measure;
@synthesize measureVote = _measureVote;
@synthesize statement = _statement;
@synthesize delegate;
@synthesize navItem = _navItem;
@synthesize textView = _textView;
@synthesize voteButton = _voteButton;
@synthesize cancelButton = _cancelButton;

// Done button clicked
- (IBAction)dismissView:(id)sender {
    // Call the delegate to dismiss the modal view
    [delegate didDismissModalView:(sender==_voteButton) toCandidate:_candidate orMeasureVote:_measureVote withOptionalStatement:_textView.text];
}

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
	if (_candidate != nil) {
		self.navItem.title = _candidate.name;
	}
	else if (_measure != nil) {
		self.navItem.title = _measure.title;
	}
	if (_statement != nil) {
		_textView.text = _statement;
	}

//	self.textView.layer.backgroundColor = [UIColor blueColor].CGColor;
	self.textView.layer.cornerRadius = 10.0f;
	self.textView.layer.borderColor = [UIColor grayColor].CGColor;
	self.textView.layer.borderWidth = 1.0f;
	[self.textView becomeFirstResponder];
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
	self.candidate = nil;
	self.measure = nil;
	self.statement = nil;
	self.navItem = nil;
    [super dealloc];
}


@end
