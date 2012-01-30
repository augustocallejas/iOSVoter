//
//  FacebookClient.m
//  Supervote
//
//  Created by augusto callejas on 11/28/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "FacebookClient.h"

#import "FacebookFriend.h"

static NSString *kFBAccessTokenKey = @"FBAccessTokenKey";
static NSString *kFBExpirationDateKey = @"FBExpirationDateKey";

// Your Facebook APP Id must be set before running this example
// See http://www.facebook.com/developers/createapp.php
// Also, your application must bind to the fb[app_id]:// URL
// scheme (substitute [app_id] for your real Facebook app id).
static NSString *kAppId = @"259602660736072";

@implementation FacebookClient

@synthesize facebook = _facebook;
@synthesize loggedIn = _loggedIn;
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark FacebookClient methods

- (id)initWithContext:(NSManagedObjectContext *)context andDocumentsPath:(NSString *)path {
	self = [super init];
	if (self) {
		_loggedIn = NO;
		_facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults objectForKey:kFBAccessTokenKey] && [defaults objectForKey:kFBExpirationDateKey]) {
			_facebook.accessToken = [defaults objectForKey:kFBAccessTokenKey];
			_facebook.expirationDate = [defaults objectForKey:kFBExpirationDateKey];
			_loggedIn = YES;
			
			NSLog(@"Loaded Facebook access token with expiration date %@", _facebook.expirationDate);
			
			[_facebook extendAccessTokenIfNeeded];
		}
		
		_context = [context retain];
		_documentsPath = [path retain];
	}
	return self;
}

- (void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:accessToken forKey:kFBAccessTokenKey];
	[defaults setObject:expiresAt forKey:kFBExpirationDateKey];
	[defaults synchronize];
}

- (void)updateFriends {
	NSLog(@"updateFriends");
	NSFileManager *manager = [NSFileManager defaultManager];
	
	NSError *error = nil;
	if (![manager createDirectoryAtPath:[NSString stringWithFormat:@"%@/facebook", _documentsPath] withIntermediateDirectories:YES attributes:nil error:&error]) {
		NSLog(@"Error while creating facebook directory: %@", [error userInfo]);
	}
	
	if (![_facebook isSessionValid]) {
		NSLog(@"session not valid");
		[_facebook authorize:nil];
	}
	
	[_facebook requestWithGraphPath:@"me/friends" andDelegate:self];
}

- (void)authorize {
	//		_permissions =  [[NSArray arrayWithObjects:
	//						  @"read_stream", @"publish_stream", @"offline_access",nil] retain];
	[_facebook authorize:nil];
}

- (void)logout {
	[_facebook logout];
}

#pragma mark -
#pragma mark FBSessionDelegate methods

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin {
	_loggedIn = YES;
	
	NSLog(@"Facebook login successful, session expiration date %@", [_facebook expirationDate]);
	/* save access token */
	[self storeAuthData:[_facebook accessToken] expiresAt:[_facebook expirationDate]];
	
	/* download the friend graph */
//	[self updateFriends];
	
	if ([_delegate respondsToSelector:@selector(fbDidLogin)]) {
		[_delegate fbDidLogin];
	}
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"Did not log in");
	
	if ([_delegate respondsToSelector:@selector(fbDidNotLogin:cancelled:)]) {
		[_delegate fbDidNotLogin:cancelled];
	}
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
	NSLog(@"token extended");
	[self storeAuthData:accessToken expiresAt:expiresAt];
}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout {
	_loggedIn = NO;
	NSLog(@"Logged out of Facebook");
	
	// Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
	
	if ([_delegate respondsToSelector:@selector(fbDidLogout)]) {
		[_delegate fbDidLogout];
	}
	
	//[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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
				NSEntityDescription *entity = [NSEntityDescription entityForName:@"FacebookFriend" inManagedObjectContext:_context];
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
						
						NSArray *array = [_context executeFetchRequest:request error:&error];
						if (array != nil) {
							NSUInteger count = [array count];
							if (count == 0) {
								NSLog(@"Facebook friend's profile photo downloaded, but not in database: '%@'", friendId);
								/* insert new facebook friend??? */
								/* create an object */
								FacebookFriend *newFriend = [(FacebookFriend *) [NSEntityDescription insertNewObjectForEntityForName:@"FacebookFriend"
																											  inManagedObjectContext:_context] retain];
								newFriend.friendId = friendId;
								newFriend.name = friendName;
								newFriend.photoDownloaded = nil;
								
								if (![_context save:&error]) {
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
						
						NSArray *array = [_context executeFetchRequest:request error:&error];
						if (array != nil) {
							NSUInteger count = [array count];
							if (count == 0) {
								NSLog(@"Creating new FacebookFriend instance for '%@', will require downloading profile photo", friendName);
								/* create an object */
								FacebookFriend *newFriend = [(FacebookFriend *) [NSEntityDescription insertNewObjectForEntityForName:@"FacebookFriend"
																											  inManagedObjectContext:_context] retain];
								newFriend.friendId = friendId;
								newFriend.name = friendName;
								newFriend.photoDownloaded = nil;
								
								if (![_context save:&error]) {
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
			
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"FacebookFriend" inManagedObjectContext:_context];
			[request setEntity:entity];		
			
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"friendId == %@", friendId];
			[request setPredicate:predicate];
			NSError *error = nil;
			
			NSArray *array = [_context executeFetchRequest:request error:&error];
			if (array != nil) {
				NSUInteger count = [array count];
				if (count == 1) {
					FacebookFriend *friend = (FacebookFriend *)[array objectAtIndex:0];
					friend.photoDownloaded = [NSDate date];
					
					if (![_context save:&error]) {
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

- (void)dealloc {
	self.delegate = nil;
	[_facebook release];
	[_context release];
	[_documentsPath release];
    [super dealloc];
}

@end
