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
@synthesize viewableByFriends = _viewableByFriends;
@synthesize viewableByFriendsLabel;
@synthesize isEditOfExisting = _isEditOfExisting;
@synthesize delegate;
@synthesize navItem = _navItem;
@synthesize endorsementHeader;
@synthesize endorsementTitle = _endorsementTitle;
@synthesize textView = _textView;
@synthesize viewableByFriendsCell = _viewableByFriendsCell;
@synthesize privacyLock = _privacyLock;
@synthesize viewableByFriendsSwitch = _viewableByFriendsSwitch;
@synthesize voteButton = _voteButton;
@synthesize cancelButton = _cancelButton;

// Done button clicked
- (IBAction)dismissView:(id)sender {
    // Call the delegate to dismiss the modal view
    [delegate didDismissModalView:(sender==_voteButton) toCandidate:_candidate orMeasureVote:_measureVote withOptionalStatement:_textView.text andViewableByFriends:_viewableByFriendsSwitch.on];
}

- (IBAction)switchedPrivacy:(id)sender {
	UISwitch *switchControl = (UISwitch*) sender;
	[_privacyLock setHidden:switchControl.on];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    NSUInteger newLength = [_textView.text length] + [string length] - range.length;
    return (newLength >= 500) ? NO : YES;
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
	
//	/* http://stackoverflow.com/questions/599405/iphone-navigation-bar-title-text-color */
//	UIFont *font = [UIFont fontWithName:@"LeagueGothic" size:30.0];
//	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
//	label.backgroundColor = [UIColor clearColor];
//	label.font = font;
//	//label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
//	label.textAlignment = UITextAlignmentCenter;
//	label.textColor = [UIColor whiteColor];
//	label.text = @"Vote";
//	[label sizeToFit];
//	_navItem.titleView = label;
//	[label release];
	
	[endorsementHeader setText:NSLocalizedString(@"EnterEndorsement", nil)];
	
	[_cancelButton setTitle:NSLocalizedString(@"Cancel", nil)];
	
	if (_candidate != nil) {
		//self.navItem.title = _candidate.name;
		self.endorsementTitle.text = _candidate.name;
	}
	else if (_measure != nil) {
		//self.navItem.title = _measure.title;
		self.endorsementTitle.text = _measure.title;
	}
	if (_statement != nil) {
		_textView.text = _statement;
	}
	if (_isEditOfExisting) {
		_voteButton.title = NSLocalizedString(@"Save", nil);
	}
	
	[viewableByFriendsLabel setText:NSLocalizedString(@"ViewableByFriends", nil)];

	[_viewableByFriendsSwitch setOn:_viewableByFriends];
	[_privacyLock setHidden:_viewableByFriends];

	_viewableByFriendsCell.layer.cornerRadius = 10.0f;
	_viewableByFriendsCell.layer.borderColor = [UIColor grayColor].CGColor;
	_viewableByFriendsCell.layer.borderWidth = 1.0f;
	
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
//	_navItem.titleView = nil;
}


- (void)dealloc {
	self.candidate = nil;
	self.measure = nil;
	self.statement = nil;
	self.navItem = nil;
    [super dealloc];
}


@end
