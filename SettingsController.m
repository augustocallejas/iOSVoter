//
//  SettingsController.m
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//

#import "SettingsController.h"

#import "FacebookFriend.h"
#import "SupervoteAppDelegate.h"

@implementation SettingsController

@synthesize facebookLabel = _facebookLabel;
@synthesize facebookLoginButton;
@synthesize advancedLabel;
@synthesize resetAppButton;

@synthesize client = _client;
@synthesize facebookClient = _facebookClient;

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		LogInfo(@"Resetting application data");
		
		NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
		[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
		
		SupervoteAppDelegate *appDelegate = (SupervoteAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate deletePersistentStoreCoordinator];
		[appDelegate deleteFacebookPhotos];
		[_facebookClient logout];
		[_client logout];
		[appDelegate switchToWelcomePage];
	}
	else if (buttonIndex == actionSheet.cancelButtonIndex) {
		/* do nothing */
		LogInfo(@"User cancelled reset application request");
	}
}

#pragma mark -
#pragma mark IBAction methods

- (IBAction)doFacebookLogin {
	if (_facebookClient.loggedIn) {
		LogInfo(@"User logged out of Facebook in Settings tab");
		[_facebookClient logout];
		[[self facebookLoginButton] setTitle:NSLocalizedString(@"LogIntoFacebookButton", nil) forState:UIControlStateNormal];
	}
	else {
		LogInfo(@"User initiating Facebook authentication in Settings tab");
		[_facebookClient authorize];
	}
}

- (IBAction)doResetApplication {
	LogInfo(@"User initiating reset application request in Settings tab");
	
	/* user wants to reset the application */
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ResetApplicationWarning", nil)
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
											   destructiveButtonTitle:NSLocalizedString(@"YES", nil)
													otherButtonTitles:nil];
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
	[actionSheet release];
}

#pragma mark -
#pragma mark Facebook delegate methods

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin {
	LogInfo(@"User completed Facebook authentication");
	[[self facebookLoginButton] setTitle:NSLocalizedString(@"LogOutOfFacebookButton", nil) forState:UIControlStateNormal];

#if USE_TESTFLIGHT
	[TestFlight passCheckpoint:@"FacebookIntegrationInSettings"];
#endif

	vote_status status = [_client sendFacebookAccessToken:[_facebookClient getAccessToken]];
	if (status != OK) {
		LogWarn(@"Network error sending Facebook access token");
	}
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
	LogInfo(@"User cancelled Facebook authentication");

#if USE_TESTFLIGHT
	[TestFlight passCheckpoint:@"CanceledFacebookIntegrationInSettings"];
#endif
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
	//  [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIFont *font = [UIFont fontWithName:@"LeagueGothic" size:22.0];
	_facebookLabel.textColor = [UIColor darkGrayColor];
	[_facebookLabel setFont:font];
	[_facebookLabel setText:NSLocalizedString(@"FacebookSettings", nil)];
	
	advancedLabel.textColor = [UIColor darkGrayColor];
	[advancedLabel setFont:font];
	[advancedLabel setText:NSLocalizedString(@"Advanced", nil)];
	[resetAppButton setTitle:NSLocalizedString(@"ResetApplicationButton", nil) forState:UIControlStateNormal];
	
#ifdef CONFIGURATION_Release
	advancedLabel.hidden = YES;
	resetAppButton.hidden = YES;
#endif
	
	if (_facebookClient != nil) {
		if (_facebookClient.loggedIn) {
			[[self facebookLoginButton] setTitle:NSLocalizedString(@"LogOutOfFacebookButton", nil) forState:UIControlStateNormal];
		}
		else {
			[[self facebookLoginButton] setTitle:NSLocalizedString(@"LogIntoFacebookButton", nil) forState:UIControlStateNormal];
		}
		
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
