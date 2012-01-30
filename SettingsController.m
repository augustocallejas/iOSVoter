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

@synthesize managedObjectContext = _managedObjectContext;
@synthesize client = _client;
@synthesize facebookClient = _facebookClient;
@synthesize documentsPath = _documentsPath;

#pragma mark -
#pragma mark SettingsController methods

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 0 && indexPath.row == 0) {
		if (_facebookClient.loggedIn) {
			[_facebookClient logout];
		}
		else {
			[_facebookClient authorize];
		}
	}
	else if (indexPath.section == 1 && indexPath.row == 0) {
		/* user wants to reset the application */		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Reset"
														message:@"Reseting the app will erase all saved data.  Are you sure?"
													   delegate:self 
											  cancelButtonTitle:@"No"
											  otherButtonTitles:@"Yes", nil];
		[alert show];
		[alert release];
	}
	else if (indexPath.section == 2 && indexPath.row == 0) {
		NSString* launchUrl = @"http://mobile.twitter.com/supervote";
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// 0 = No, 1 = Yes
	if (buttonIndex == 1) {
		NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
		[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
		
		SupervoteAppDelegate *appDelegate = (SupervoteAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate deletePersistentStoreCoordinator];
		[appDelegate deleteFacebookPhotos];
		[_facebookClient logout];
		//appDelegate.managedObjectContext = nil;
		[appDelegate switchToWelcomePage];
	}
}

#pragma mark -
#pragma mark FBSessionDelegate methods

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin {
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	
	vote_status status = [_client sendFacebookAccessToken:[[_facebookClient facebook] accessToken]];
	if (status == OK) {
		[_facebookClient updateFriends];
	}
	else {
		NSString *title = nil;
		NSString *message = nil;
		
		switch (status) {
			case OK:
				break;
			case HTTP_ERROR:
				title = @"Network Error";
				message = @"Unable to connect to server, please verify your network connection and try again.";
				break;
			case SERVER_ERROR:
				title = @"Server Error";
				message = @"Unable to retrieve elections from server, please try again in a few minutes.";
				break;
			case BAD_REQUEST:
				title = @"Bad Request";
				message = @"The app sent a bad request to the server.";
				break;
			case UNEXPECTED_RESPONSE:
			default:
				title = @"Unexpected Response";
				message	= @"The server returned an unexpected response.";
				break;
		}
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
														message:message 
													   delegate:nil 
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"Facebook Login cancelled");
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
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/* Facebook */
	if (section == 0) {
		return 1;
	}
	/* Reset */
	else if (section == 1) {
		return 1;
	}
	/* Twitter Link */
	else if (section == 2) {
		return 1;
	}
	
	return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		return @"Facebook Settings";
	}
	else if (section == 1) {
		return @"Application Settings"; 
	}
	else if (section == 2) {
		return @"Social Media";
	}
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"] autorelease];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	}

	if (indexPath.section == 0 && indexPath.row == 0) {
		if (_facebookClient.loggedIn) {
			cell.textLabel.text = @"Log out of Facebook";
		}
		else {
			cell.textLabel.text = @"Log into Facebook";
		}
	}
	else if (indexPath.section == 1 && indexPath.row == 0) {
		cell.textLabel.text = @"Reset Application";
	}
	else if (indexPath.section == 2 && indexPath.row == 0) {
		cell.textLabel.text = @"Follow us on Twitter";
	}
	
	//NSString *path = [[NSBundle mainBundle] pathForResource:@"users" ofType:@"png"]; 
	//UIImage *icon = [UIImage imageWithContentsOfFile:path];
	//cell.imageView.image = icon;
	
	return cell;
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
	self.managedObjectContext = nil;
	self.client = nil;
	self.facebookClient = nil;
	self.documentsPath = nil;
    [super dealloc];
}


@end
