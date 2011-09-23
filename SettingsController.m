//
//  SettingsController.m
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//

#import "SettingsController.h"

// Your Facebook APP Id must be set before running this example
// See http://www.facebook.com/developers/createapp.php
// Also, your application must bind to the fb[app_id]:// URL
// scheme (substitute [app_id] for your real Facebook app id).
static NSString* kAppId = @"259602660736072";

@implementation SettingsController

@synthesize facebook = _facebook;

#pragma mark -
#pragma mark SettingsController methods

- (void) login {
	  [_facebook authorize:nil];
}


#pragma mark -
#pragma mark FBSessionDelegate methods

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin {
	NSLog(@"Did log in");
	
	[_facebook requestWithGraphPath:@"me/friends" andDelegate:self];
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"Did not log in");
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout {
	NSLog(@"Logged out");
}


#pragma mark -
#pragma mark FBRequestDelegate methods

/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBRequest *)request {
	NSLog(@"FB: request loading");
}

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"FB: request did receive response");
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"FB: request did fail with error");
	NSLog(@"error %@", error);
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
	//NSLog(@"requestDidLoad %@", [request url]);
	
	if ([[request url] hasSuffix:@"me/friends"])
	{
		if ([result isKindOfClass:[NSDictionary class]]) {
			NSDictionary *dict = (NSDictionary *)result;
			
			BOOL queryForImage = YES;
			
			id object = [dict objectForKey:@"data"];
			if (object != nil && [object isKindOfClass:[NSArray class]]) {
				NSArray *friendList = (NSArray *)object;
				for (id friend in friendList) {
					NSDictionary *friendInfo = (NSDictionary *)friend;
					NSString *friendId = (NSString *)[friendInfo objectForKey:@"id"];
					NSString *friendName = (NSString *)[friendInfo objectForKey:@"name"];
										
					if (queryForImage) {
						queryForImage = NO;
						//NSLog(@"saving %@", friendName);
						[_facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/picture", friendId]  andDelegate:self];
					}
					
					//NSLog(@"%d -> %@", [friendId intValue], friendName);
				}
			}
		}
	}
	else {
		//NSLog(@"result %@", result);
	}
}

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data {
	if ([[request url] hasSuffix:@"/picture"]) {
		NSUInteger lastForwardSlash = [[request url] length] - 8;
		NSRange range = [[request url] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]
													   options:NSBackwardsSearch
														 range:NSMakeRange(0, lastForwardSlash)];
		NSString *friendId = [[request url] substringWithRange:NSMakeRange(range.location+1, lastForwardSlash-range.location-1)];
		//NSLog(@"[%@]", friendId);

		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		/* TODO: create facebook directory beforehand */
		NSString *filePath = [NSString stringWithFormat:@"%@/facebook/%@.gif", documentsDirectory, friendId];
		
		if ([data writeToFile:filePath atomically:YES]) {
			NSLog(@"saved!");
		}
		else {
			NSLog(@"not saved!");
		}
	}
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self login];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
	{
		return 1;
	}
	
	return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
	{
		return @"Settings";
	}
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
	
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"default"] autorelease];
	}
	
	cell.textLabel.text = @"Facebook";
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"users" ofType:@"png"]; 
	UIImage *icon = [UIImage imageWithContentsOfFile:path];
	cell.imageView.image = icon;
	
	return cell;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		//		_permissions =  [[NSArray arrayWithObjects:
		//						  @"read_stream", @"publish_stream", @"offline_access",nil] retain];
		_facebook = [[Facebook alloc] initWithAppId:kAppId
										andDelegate:self];
    }
    return self;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
	self.facebook = nil;
    [super dealloc];
}


@end
