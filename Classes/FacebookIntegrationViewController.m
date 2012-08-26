//
//  FacebookIntegrationViewController.m
//  Supervote
//
//  Created by augusto callejas on 1/29/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "FacebookIntegrationViewController.h"

#import "SupervoteAppDelegate.h"

@implementation FacebookIntegrationViewController

@synthesize titleLabel = _titleLabel;
@synthesize facebookMessage;
@synthesize client = _client;
@synthesize facebookClient = _facebookClient;
@synthesize facebookLoginButton;
@synthesize noThanksButton;

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
	
	UIFont *font = [UIFont fontWithName:@"LeagueGothic" size:40.0];
	[_titleLabel setFont:font];
	
	[_titleLabel setText:NSLocalizedString(@"Setup", nil)];
	[facebookMessage setText:NSLocalizedString(@"FacebookSetup", nil)];
	
	[noThanksButton setTitle:NSLocalizedString(@"NoThanks", nil) forState:UIControlStateNormal];
	
	/* TODO: why would facebookClient be null? */
	if (_facebookClient != nil) {
		UIImage *icon1 = [UIImage imageNamed:@"LoginWithFacebookNormal.png"];
		UIImage *icon2 = [UIImage imageNamed:@"LoginWithFacebookPressed.png"];
		[[self facebookLoginButton] setImage:icon1 forState:UIControlStateNormal];
		[[self facebookLoginButton] setImage:icon2 forState:UIControlStateHighlighted];
	}
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Custom IBAction methods

- (void)markAsViewed {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@"1" forKey:@"FacebookAlert"];
	[defaults synchronize];
}

- (IBAction)doYesFacebookIntegration {
	LogInfo(@"User selected Facebook integration");
	[_facebookClient authorize:self];
}

- (IBAction)doNoFacebookIntegration {
	LogInfo(@"User opted out of Facebook integration");
	[self markAsViewed];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LaterFacebookTitle", nil)
													message:NSLocalizedString(@"LaterFacebookMessage", nil)
												   delegate:nil 
										  cancelButtonTitle:NSLocalizedString(@"OK", nil)
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	SupervoteAppDelegate *appDelegate = (SupervoteAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate switchToMainApp:self.view];
}


/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin {
	[self markAsViewed];
	
	[TestFlight passCheckpoint:@"FacebookIntegration"];
	
	/* TODO: same logic as in SettingsController */
	vote_status status = [_client sendFacebookAccessToken:[_facebookClient getAccessToken]];
	if (status == OK) {
		[_facebookClient updateFriends];
	}
	else {
		LogWarn(@"Network error sending Facebook access token");
	}

	SupervoteAppDelegate *appDelegate = (SupervoteAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate switchToMainApp:self.view];
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin {
	[self markAsViewed];
	
	[TestFlight passCheckpoint:@"CanceledFacebookIntegration"];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LaterFacebookTitle", nil)
													message:NSLocalizedString(@"LaterFacebookMessage", nil)
												   delegate:nil 
										  cancelButtonTitle:nil
										  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alert show];
	[alert release];

	SupervoteAppDelegate *appDelegate = (SupervoteAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate switchToMainApp:self.view];
}

#pragma mark -
#pragma mark General methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	if (_facebookClient != nil) {
//		_facebookClient.delegate = nil;
	}
}


- (void)dealloc {
	self.client = nil;
	self.facebookClient = nil;
    [super dealloc];
}


@end
