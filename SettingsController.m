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
#pragma mark IBAction methods

- (IBAction)doFacebookLogin {
	if ([_facebookClient isLoggedIn]) {
		LogInfo(@"User logged out of Facebook in Settings tab");
		[_facebookClient logout];
	}
	else {
		LogInfo(@"User initiating Facebook authentication in Settings tab");
		[_facebookClient authorize:self];
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
#pragma mark NSNotificationCenter methods

- (void)sessionStateChanged:(NSNotification*)notification {
	//			UIImage *icon1 = [UIImage imageNamed:@"LoginWithFacebookNormal.png"];
	//			UIImage *icon2 = [UIImage imageNamed:@"LoginWithFacebookPressed.png"];
	//			[[self facebookLoginButton] setImage:icon1 forState:UIControlStateNormal];
	//			[[self facebookLoginButton] setImage:icon2 forState:UIControlStateHighlighted];
	
	//	UIImage *icon1 = [UIImage imageNamed:@"LogoutNormal.png"];
	//	UIImage *icon2 = [UIImage imageNamed:@"LogoutPressed.png"];
	//	[[self facebookLoginButton] setImage:icon1 forState:UIControlStateNormal];
	//	[[self facebookLoginButton] setImage:icon2 forState:UIControlStateHighlighted];
	
	if ([_facebookClient isLoggedIn]) {
		[[self facebookLoginButton] setTitle:NSLocalizedString(@"LogOutOfFacebookButton", nil) forState:UIControlStateNormal];

    } else {
		[[self facebookLoginButton] setTitle:NSLocalizedString(@"LogIntoFacebookButton", nil) forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark Facebook delegate methods

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin {
	LogInfo(@"User completed Facebook authentication");

	[TestFlight passCheckpoint:@"FacebookIntegrationInSettings"];

	vote_status status = [_client sendFacebookAccessToken:[_facebookClient getAccessToken]];
	if (status == OK) {
//		[_facebookClient updateFriends];
	}
	else {
		LogWarn(@"Network error sending Facebook access token");
	}
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin {
	LogInfo(@"User cancelled Facebook authentication");
	
	[TestFlight passCheckpoint:@"CanceledFacebookIntegrationInSettings"];
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

#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(sessionStateChanged:)
		name:FBSessionStateChangedNotification
		object:nil];
	
	UIFont *font = [UIFont fontWithName:@"LeagueGothic" size:22.0];
	_facebookLabel.textColor = [UIColor darkGrayColor];
	[_facebookLabel setFont:font];
	[_facebookLabel setText:NSLocalizedString(@"FacebookSettings", nil)];
	
	advancedLabel.textColor = [UIColor darkGrayColor];
	[advancedLabel setFont:font];
	[advancedLabel setText:NSLocalizedString(@"Advanced", nil)];
	[resetAppButton setTitle:NSLocalizedString(@"ResetApplicationButton", nil) forState:UIControlStateNormal];
	
	if (_facebookClient != nil) {
		if ([_facebookClient isLoggedIn]) {
			[[self facebookLoginButton] setTitle:NSLocalizedString(@"LogOutOfFacebookButton", nil) forState:UIControlStateNormal];

		}
		else {
			[[self facebookLoginButton] setTitle:NSLocalizedString(@"LogIntoFacebookButton", nil) forState:UIControlStateNormal];

		}
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
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
	self.client = nil;
	self.facebookClient = nil;
    [super dealloc];
}


@end
