//
//  SettingsController.m
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//

#import "SettingsController.h"

#import "FacebookFriend.h"

// Your Facebook APP Id must be set before running this example
// See http://www.facebook.com/developers/createapp.php
// Also, your application must bind to the fb[app_id]:// URL
// scheme (substitute [app_id] for your real Facebook app id).
static NSString* kAppId = @"259602660736072";

@implementation SettingsController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize facebook = _facebook;
@synthesize documentsPath = _documentsPath;

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
	_loggedIn = YES;
	
	NSLog(@"Facebook login successful, session expiration date %@", [_facebook expirationDate]);
	/* TODO: save access token */
//	NSLog(@"%@", [_facebook accessToken]);
	
	/* reload table cell so that it refreshes its view */
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	
	/* download the friend graph */
	[_facebook requestWithGraphPath:@"me/friends" andDelegate:self];
	
	[client sendFacebookAccessToken:[_facebook accessToken]];
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
	//_loggedIn = NO;
	NSLog(@"Did not log in");
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout {
	_loggedIn = NO;
	NSLog(@"Logged out of Facebook");
	
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark -
#pragma mark FBRequestDelegate methods

/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBRequest *)request {
	//NSLog(@"FB: request loading");
}

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	//NSLog(@"FB: request did receive response");
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
			
			id object = [dict objectForKey:@"data"];
			if (object != nil && [object isKindOfClass:[NSArray class]]) {
				NSArray *friendList = (NSArray *)object;
				
				/* query for each user */
				NSFetchRequest *request = [[NSFetchRequest alloc] init];
				[request setFetchLimit:1];
				NSEntityDescription *entity = [NSEntityDescription entityForName:@"FacebookFriend" inManagedObjectContext:_managedObjectContext];
				[request setEntity:entity];			
				NSError *error = nil;
				
				for (id friend in friendList) {
					NSDictionary *friendInfo = (NSDictionary *)friend;
					NSString *friendId = (NSString *)[friendInfo objectForKey:@"id"];
					NSString *friendName = (NSString *)[friendInfo objectForKey:@"name"];
					
					/* TODO: check if any friends have been deleted? */
					
					/* check if the friend's profile photo has already been downloaded */
					NSString *filePath = [NSString stringWithFormat:@"%@/facebook/%@.gif", _documentsPath, friendId];					
					if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
						/* the file exists, but perhaps it was partially downloaded?
						query for the FacebookFriend instance */
						
						NSPredicate *predicate = [NSPredicate predicateWithFormat:@"friendId == %@", friendId];
						[request setPredicate:predicate];
						
						NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
						if (array != nil) {
							NSUInteger count = [array count];
							if (count == 0) {
								NSLog(@"Facebook friend's profile photo downloaded, but not in database: '%@'", friendId);
								/* insert new facebook friend??? */
								/* create an object */
								FacebookFriend *newFriend = [(FacebookFriend *) [NSEntityDescription insertNewObjectForEntityForName:@"FacebookFriend"
																											  inManagedObjectContext:_managedObjectContext] retain];
								newFriend.friendId = friendId;
								newFriend.name = friendName;
								newFriend.photoDownloaded = nil;
								
								if (![_managedObjectContext save:&error]) {
									NSLog(@"Failed to save managed object context: %@", [error userInfo]);
								}
								else {
									//[_facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/picture", friendId] andDelegate:self];
								}

							}
							else if (count == 1) {
								FacebookFriend *friend = (FacebookFriend *)[array objectAtIndex:0];
								if (friend.photoDownloaded == nil) {
									/* profile photo downloaded, but not marked complete, redownload */
									NSLog(@"Redownloading photo for '%@' since no photoDownloaded date exists", friend.name);
									[_facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/picture", friendId] andDelegate:self];									
								}
								else {
									/* TODO: how do i check if the photo is out of date? */
									/* TODO: how can we check if the profile photo has changed? */
									NSLog(@"Profile photo for '%@' already exists, not re-downloading", friendName);
								}
							}
						}
						else {
							NSLog(@"Query failed for FacebookFriend instance (friendId=%@): %@", friendId, [error userInfo]);
						}
					}
					else {
						/* the facebook friend's profile photo is not downloaded */
						NSPredicate *predicate = [NSPredicate predicateWithFormat:@"friendId == %@", friendId];
						[request setPredicate:predicate];
						
						NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
						if (array != nil) {
							NSUInteger count = [array count];
							if (count == 0) {
								NSLog(@"Creating new FacebookFriend instance for '%@', will require downloading profile photo", friendName);
								/* create an object */
								FacebookFriend *newFriend = [(FacebookFriend *) [NSEntityDescription insertNewObjectForEntityForName:@"FacebookFriend"
																											  inManagedObjectContext:_managedObjectContext] retain];
								newFriend.friendId = friendId;
								newFriend.name = friendName;
								newFriend.photoDownloaded = nil;
								
								if (![_managedObjectContext save:&error]) {
									NSLog(@"Failed to save managed object context: %@", [error userInfo]);
									// Handle the error
								}
							}
							else if (count == 1) {
								FacebookFriend *friend = (FacebookFriend *)[array objectAtIndex:0];
								NSLog(@"Profile photo for '%@' is missing, will redownload", friend.name);
							}
							
							NSLog(@"Downloading profile photo for '%@' to file '%@.gif'", friendName, friendId);
							[_facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/picture", friendId] andDelegate:self];
						}
						else {
							NSLog(@"Query failed for FacebookFriend instance (friendId=%@): %@", friendId, [error userInfo]);
						}
					}
				}
				
				[request release];
			}
		}
		
		NSError *error = nil;
		NSArray *friends = [client getFriends];
		[client insertFriends:friends intoManagedContext:_managedObjectContext withError:&error];
		
		if (error != nil) {
			NSLog(@"error: %@", [error userInfo]);
		}
		
		error = nil;
		/* TODO: not a real election guid */
		NSArray *votes = [client getVotesForBallot:@"test"];
		[client insertVotes:votes intoManagedContext:_managedObjectContext withError:&error];
		
		if (error != nil) {
			NSLog(@"error: %@", [error userInfo]);
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

		/* TODO: create facebook directory beforehand */
		NSString *filePath = [NSString stringWithFormat:@"%@/facebook/%@.gif", _documentsPath, friendId];
		
		if ([data writeToFile:filePath atomically:YES]) {
			NSLog(@"Successfully downloaded Facebook friend's profile photo: '%@'", friendId);

			/* update the photoDownloaded attribute in FacebookFriend object */
			NSFetchRequest *request = [[NSFetchRequest alloc] init];
			[request setFetchLimit:1];
			
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"FacebookFriend" inManagedObjectContext:_managedObjectContext];
			[request setEntity:entity];		

			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"friendId == %@", friendId];
			[request setPredicate:predicate];
			NSError *error = nil;
			
			NSArray *array = [_managedObjectContext executeFetchRequest:request error:&error];
			if (array != nil) {
				NSUInteger count = [array count];
				if (count == 1) {
					FacebookFriend *friend = (FacebookFriend *)[array objectAtIndex:0];
					friend.photoDownloaded = [NSDate date];
					
					if (![_managedObjectContext save:&error]) {
						NSLog(@"Failed to save managed object context: %@", [error userInfo]);
					}
					else {
						//NSLog(@"Saved with date: %@", friend.photoDownloaded);
					}
				}
				else if (count == 0) {
					NSLog(@"Missing FacebookFriend instance (friendId=%@) despite downloading photo", friendId);
				}
			}
			else {
				NSLog(@"Query failed for FacebookFriend instance (friendId=%@): %@", friendId, [error userInfo]);
			}
		}
		else {
			/* TODO: does writeToFile set an error flag? */
			NSLog(@"Failed to save Facebook friend's profile photo: %@", friendId);
		}
	}
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 0 && indexPath.row == 0) {
		if (_loggedIn) {
			[_facebook logout:self];
		}
		else {
			[self login];
		}
	}
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/* Facebook */
	if (section == 0) {
		return 1;
	}
	
	return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
	{
		return @"Facebook Settings";
	}
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
	
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"] autorelease];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	}

	if (_loggedIn) {
		cell.textLabel.text = @"Log out of Facebook";
	}
	else {
		cell.textLabel.text = @"Log into Facebook";
	}

//	cell.textLabel.text = @"Facebook";
//	if (_loggedIn) {
//		cell.detailTextLabel.text = @"Logged in";
//	}
//	else {
//		cell.detailTextLabel.text = @"Logged out";
//	}

		
	if ([_facebook isSessionValid]) {
	}
	else {
		//
	}

	
	//NSString *path = [[NSBundle mainBundle] pathForResource:@"users" ofType:@"png"]; 
	//UIImage *icon = [UIImage imageWithContentsOfFile:path];
	//cell.imageView.image = icon;
	
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
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		_documentsPath = [[paths objectAtIndex:0] retain];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	client = [[SupervoteClient alloc] init];
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
	[client release];
}


- (void)dealloc {
	self.managedObjectContext = nil;
	self.facebook = nil;
	self.documentsPath = nil;
    [super dealloc];
}


@end
