//
//  FacebookClient.m
//  Supervote
//
//  Created by augusto callejas on 11/28/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "FacebookClient.h"

#import "FacebookFriend.h"
#import "SupervoteAppDelegate.h"

@interface DownloadFacebookPhoto : NSObject
{
@private
	NSMutableData *data;
}

@property (nonatomic, retain) NSString *friendId;
@property (nonatomic, retain) FacebookClient *client;

@end

@implementation DownloadFacebookPhoto

@synthesize friendId;
@synthesize client;

- (id)init {
	self = [super init];
	if (self) {
		data = [[NSMutableData data] retain];
	}
	return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)mdata {
	[data appendData: mdata];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self.client saveFacebookPhoto:data forFriend:friendId];
	[connection release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	LogError(@"Facebook Photo download failed: %@", [error localizedDescription]);
	[connection release];
};

- (void)dealloc {
	self.friendId = nil;
	self.client = nil;
	[data release];
	[super dealloc];
}

@end


@implementation FacebookClient

#pragma mark -
#pragma mark FacebookClient methods

+ (BOOL)handleOpenURL:(NSURL *)url {
	return [[FBSession activeSession] handleOpenURL:url];
}

- (id)initWithContext:(NSManagedObjectContext *)context andDocumentsPath:(NSString *)path {
	self = [super init];
	if (self) {
//		_loggedIn = NO;
//		_facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
//		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//		if ([defaults objectForKey:kFBAccessTokenKey] && [defaults objectForKey:kFBExpirationDateKey]) {
//			_facebook.accessToken = [defaults objectForKey:kFBAccessTokenKey];
//			_facebook.expirationDate = [defaults objectForKey:kFBExpirationDateKey];
//			_loggedIn = YES;
//			
//			LogInfo(@"Loaded Facebook access token with expiration date %@", _facebook.expirationDate);
//			LogInfo(@"Extending Facebook access token if needed");
//			[_facebook extendAccessTokenIfNeeded];
//		}
		if (![[FBSession activeSession] isOpen]) {
			SupervoteAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
			if ([delegate openSessionWithAllowLoginUI:NO withDelegate:nil]) {
				LogInfo(@"Facebook session was closed but re-opened");
			}
			else {
				LogWarn(@"Facebook session was closed but not able to re-open");
			}

		}
		
		_context = [context retain];
		_documentsPath = [path retain];
	}
	return self;
}

- (BOOL)isLoggedIn {
	return [FBSession activeSession].isOpen;
}

- (NSString *)getAccessToken {
	return [FBSession activeSession].accessToken;
}


/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)myFriendsRequest:(id)result {
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
							LogInfo(@"Facebook friend's profile photo downloaded, but not in database: '%@'", friendId);
							/* insert new facebook friend??? */
							/* create an object */
							FacebookFriend *newFriend = [(FacebookFriend *) [NSEntityDescription insertNewObjectForEntityForName:@"FacebookFriend"
																										  inManagedObjectContext:_context] retain];
							newFriend.friendId = friendId;
							newFriend.name = friendName;
							newFriend.photoDownloaded = nil;
							
							if (![_context save:&error]) {
								LogError(@"Error while saving FacebookFriend instance: %@", [error localizedDescription]);
							}
							else {
								//[_facebook requestWithGraphPath:[NSString stringWithFormat:@"%@/picture", friendId] andDelegate:self];
							}
							
						}
						else if (count == 1) {
							FacebookFriend *friend = (FacebookFriend *)[array objectAtIndex:0];
							if (friend.photoDownloaded == nil) {
								/* profile photo downloaded, but not marked complete, redownload */
								LogDebug(@"Redownloading photo for '%@' since no photoDownloaded date exists", friend.name);
								[self downloadFacebookPhoto:friendId];							
							}
							else {
								/* TODO: how do i check if the photo is out of date? */
								/* TODO: how can we check if the profile photo has changed? */
								LogDebug(@"Profile photo for '%@' already exists, not re-downloading", friendName);
							}
						}
					}
					else {
						LogError(@"Query failed for FacebookFriend instance (friendId=%@): %@", friendId, [error localizedDescription]);
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
							LogDebug(@"Creating new FacebookFriend instance for '%@', will require downloading profile photo", friendName);
							/* create an object */
							FacebookFriend *newFriend = [(FacebookFriend *) [NSEntityDescription insertNewObjectForEntityForName:@"FacebookFriend"
																										  inManagedObjectContext:_context] retain];
							newFriend.friendId = friendId;
							newFriend.name = friendName;
							newFriend.photoDownloaded = nil;
							
							if (![_context save:&error]) {
								LogError(@"Error while saving FacebookFriend instance: %@", [error localizedDescription]);
							}
						}
						else if (count == 1) {
							FacebookFriend *friend = [array objectAtIndex:0];
							LogDebug(@"Profile photo for '%@' is missing, will redownload", friend.name);
						}
						
						[self downloadFacebookPhoto:friendId];
					}
					else {
						LogError(@"Query failed for FacebookFriend instance (friendId=%@): %@", friendId, [error localizedDescription]);
					}
				}
			}
			
			[request release];
		}
	}
}

- (void)updateFriends {
	LogInfo(@"Updating local Facebook friends");
	
	NSFileManager *manager = [NSFileManager defaultManager];
	
	NSError *error = nil;
	if (![manager createDirectoryAtPath:[NSString stringWithFormat:@"%@/facebook", _documentsPath] withIntermediateDirectories:YES attributes:nil error:&error]) {
		LogError(@"Error while creating facebook directory: %@", [error localizedDescription]);
	}
	
	if (![FBSession activeSession].isOpen) {
		LogInfo(@"Facebook session not valid, need to reauthorize");
		[self authorize:nil];
	}
	
	if ([FBSession activeSession].isOpen) {
		[FBRequestConnection
		 startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection,
												  id request,
												  NSError *error) {
			 
			 if (error) {
				 LogError(@"Error while retrieving Facebook friend data: %@", [error localizedDescription]);
			 }
			 else {
				 [self myFriendsRequest:request];
			 }
		 }];}
}

- (void)authorize:(id)delegate {
	//		_permissions =  [[NSArray arrayWithObjects:
	//						  @"read_stream", @"publish_stream", @"offline_access",nil] retain];
	
	SupervoteAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate openSessionWithAllowLoginUI:YES withDelegate:delegate];
}

- (void)logout {
	SupervoteAppDelegate *delegate = [[UIApplication sharedApplication] delegate];

	// If the user is authenticated, log out when the button is clicked.
    if ([FBSession activeSession].isOpen) {
        [delegate closeSession];
	}
}

- (void)downloadFacebookPhoto:(NSString *)friendId {
	LogDebug(@"Downloading profile photo to file '%@.gif'", friendId);
	
	NSString *url = [NSString stringWithFormat:@"%@/%@/picture", FBGraphBasePath, friendId];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	
	DownloadFacebookPhoto *download = [[DownloadFacebookPhoto alloc] init];
	download.client = self;
	download.friendId = friendId;
	
	/* the delegate will release this connection */
	[[NSURLConnection alloc] initWithRequest:request delegate:download startImmediately:YES];
	/* The connection retains delegate. It releases delegate when the connection finishes loading, fails, or is canceled. */
	[download release];
}

- (void)saveFacebookPhoto:(NSData *)data forFriend:(NSString *)friendId {
	NSString *filePath = [NSString stringWithFormat:@"%@/facebook/%@.gif", _documentsPath, friendId];
	
	if ([data writeToFile:filePath atomically:YES]) {
		LogDebug(@"Successfully downloaded Facebook friend's profile photo: '%@'", friendId);
		
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
					LogError(@"Failed to save managed object context: %@", [error localizedDescription]);
				}
			}
			else if (count == 0) {
				LogWarn(@"Missing FacebookFriend instance (friendId=%@) despite downloading photo", friendId);
			}
		}
		else {
			LogError(@"Query failed for FacebookFriend instance (friendId=%@): %@", friendId, [error localizedDescription]);
		}
	}
	else {
		/* TODO: does writeToFile set an error flag? */
		LogWarn(@"Failed to save Facebook friend's profile photo: %@", friendId);
	}
}


- (void)dealloc {
	[_context release];
	[_documentsPath release];
    [super dealloc];
}

@end
