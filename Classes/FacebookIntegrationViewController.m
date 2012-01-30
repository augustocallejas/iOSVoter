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

@synthesize client = _client;
@synthesize facebookClient = _facebookClient;

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
	
	if (_facebookClient != nil) {
		_facebookClient.delegate = self;
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
	NSLog(@"doYesFacebookIntegration");
	[_facebookClient authorize];
}

- (IBAction)doNoFacebookIntegration {
	[self markAsViewed];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Setup"
													message:@"You can set up Facebook access anytime in the Settings tab below."
												   delegate:nil 
										  cancelButtonTitle:nil
										  otherButtonTitles:@"Ok", nil];
	[alert show];
	[alert release];
	
	SupervoteAppDelegate *appDelegate = (SupervoteAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate switchToMainApp:self.view];
}

#pragma mark -
#pragma mark FBSessionDelegate methods

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin {
	[self markAsViewed];
	
	/* TODO: same logic as in SettingsController */
	vote_status status = [_client sendFacebookAccessToken:[[_facebookClient facebook] accessToken]];
	if (status == OK) {
		[_facebookClient updateFriends];
	}
	else {
	}

	
	SupervoteAppDelegate *appDelegate = (SupervoteAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate switchToMainApp:self.view];
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
	[self markAsViewed];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Setup"
													message:@"You can setup Facebook access anytime in the Settings tab below."
												   delegate:nil 
										  cancelButtonTitle:nil
										  otherButtonTitles:@"Ok", nil];
	[alert show];
	[alert release];

	SupervoteAppDelegate *appDelegate = (SupervoteAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate switchToMainApp:self.view];
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
}

- (void)fbDidLogout {
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated {
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
		_facebookClient.delegate = nil;
	}
}


- (void)dealloc {
	self.client = nil;
	self.facebookClient = nil;
    [super dealloc];
}


@end
