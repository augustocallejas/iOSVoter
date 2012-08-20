//
//  SupervoteAppDelegate.m
//  Supervote
//
//  Created by augusto callejas on 8/2/11.
//  Copyright 2011 Canary Falls LLC. All rights reserved.
//

#import "SupervoteAppDelegate.h"

#import "AboutUsViewController.h"
#import "FacebookClient.h"
#import "FacebookIntegrationViewController.h"
#import "FeedController.h"
#import "Friend.h"
#import "ListElectionsController.h"
#import "NSArray+PerformSelector.h"
#import "QuickTutorialViewController.h"
#import "SettingsController.h"
#import "SupervoteViewController.h"
#import "VoterRegistrationViewController.h"

#define TESTING 1

@implementation SupervoteAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize mainAppController;
@synthesize segmentsController;
@synthesize segmentedControl;
@synthesize managedObjectContext;
@synthesize facebookClient;
@synthesize supervoteClient;
@synthesize lastRefreshDate = _lastRefreshDate;


// Pre 4.2 support
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if (facebookClient != nil) {
		return [facebookClient.facebook handleOpenURL:url];
	}
	
	return NO;
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	if (facebookClient != nil) {
		return [facebookClient.facebook handleOpenURL:url];
	}
	
	return NO;
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	runningUpdate = NO;
	
	/* http://blog.goosoftware.co.uk/2012/04/18/unique-identifier-no-warnings/ */
#ifdef TESTING
	[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
	[TestFlight takeOff:@"08e9cf49dda0f6525984558248826e2c_MTE3ODE0MjAxMi0wOC0wNCAyMDo0OTozMy43MDgwMDA"];
	
	[TestFlight passCheckpoint:@"FirstCheckpoint"];
	
    // Override point for customization after application launch.
	NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
										  [NSNumber numberWithBool:NO], @"SocialBallotMode",
										  nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	
	NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
	LogInfo(@"Current language: %@", language);

	supervoteClient = [[SupervoteClient alloc] initWithContext:self.managedObjectContext];
	facebookClient = [[FacebookClient alloc] initWithContext:self.managedObjectContext andDocumentsPath:documentsPath];
	
	if (![supervoteClient isRegistered]) {
		[self switchToWelcomePage];
	}
	else {
		[self switchToMainApp:nil];
	}
	[self.window makeKeyAndVisible];
	
	return YES;
}

- (void)switchToWelcomePage {
	SupervoteViewController *controller = [[SupervoteViewController alloc] initWithNibName:@"SupervoteViewController" bundle:nil];
	controller.client = supervoteClient;
	self.viewController = controller;
	self.window.rootViewController = controller;
//		//	[self.window addSubview:self.viewController.view];
//		//	[self.viewController.view release];
	[controller release];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	[self updateDataAsynchronously:NO withDelegate:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark -
#pragma mark SupervoteAppDelegate methods

/* TODO: doesn't manage deleted elections or past elections (this may not be true at this point) */
- (void)updateData:(BOOL)withAlerts {
	if (runningUpdate) {
		LogDebug(@"Currently updating, so ignoring this request");
		return;
	}
	runningUpdate = YES;
	
	_lastRefreshDate = [[NSDate date] retain];
	
	NSError *storeError = nil;
	NSArray *friends = [supervoteClient getFriends];
	if (friends != nil) {
		NSMutableArray *newFriends = nil;
		[supervoteClient insertFriends:friends withNewFriends:&newFriends withError:&storeError];
		
		if (storeError != nil) {
			LogError(@"Store error while inserting friends: %@", [storeError localizedDescription]);
		}
		else {
			for (Friend* friend in newFriends) {
				if (friend.facebookId != nil) {
					LogInfo(@"Downloading Facebook photo for new friend: %@", friend.name);
					[facebookClient downloadFacebookPhoto:friend.facebookId];
				}
			}
		}
		
	}
	
	vote_status status = OK;
	NSDictionary *elections = [supervoteClient getElections:&status];
	
	if (elections == nil) {
		/* nil means we couldn't contact the server */
		NSString *title = nil;
		NSString *message = nil;
		switch (status) {
			case HTTP_ERROR:
				title = NSLocalizedString(@"HttpErrorTitle", nil);
				message = NSLocalizedString(@"HttpErrorMessage", nil);
				break;
			case SERVER_ERROR:
				title = NSLocalizedString(@"ServerErrorTitle", nil);
				message = NSLocalizedString(@"ListElectionsServerErrorMessage", nil);
				break;
			case BAD_REQUEST:
				title = NSLocalizedString(@"BadRequestTitle", nil);
				message = NSLocalizedString(@"BadRequestMessage", nil);
				break;
			case UNEXPECTED_RESPONSE:
			default:
				title = NSLocalizedString(@"UnexpectedResponseTitle", nil);
				message	= NSLocalizedString(@"UnexpectedResponseMessage", nil);
				break;
		}
		
		if (withAlerts) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
															message:message 
														   delegate:nil 
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
	else {
		NSError *httpError = nil;
		for (NSString *electionGuid in elections) {
			double timestamp = [((NSNumber *)[elections objectForKey:electionGuid]) doubleValue] / 1000.0;
			NSDate *lastModified = [NSDate dateWithTimeIntervalSince1970:timestamp];
			NSDate *newLastModified = nil;
			Election *electionObj = [supervoteClient getObject:@"Election" byGuid:electionGuid];
			httpError = nil;
			
			if (electionObj == nil || [electionObj.lastModified timeIntervalSinceDate:lastModified] <= -1.0) {
				/* get election from server */
				NSDictionary *election = nil;
				election_status status  = [supervoteClient getElection:&election
															  withGuid:electionGuid
													  withLastModified:nil
												   withNewModifiedTime:&newLastModified
															 withError:&httpError];
				
				if (httpError != nil) {
					LogError(@"Network error while fetching election: %@", [httpError localizedDescription]);
				}
				else if (status == ES_OK) {
					if (electionObj == nil) {
						LogInfo(@"Election '%@' not in database, going to insert it", electionGuid);
						
						if (election != nil) {
							NSError *storeError = nil;
							if (![supervoteClient insertElection:election withLastModified:newLastModified withError:&storeError]) {
								if (storeError != nil) {
									LogError(@"Storage error while inserting election: %@", [storeError localizedDescription]);
								}
							}
						}
					}
					else {
						LogInfo(@"Election '%@' needs updates (local %@ versus server %@)", electionGuid, electionObj.lastModified, lastModified);
						
						if (election != nil) {
							NSError *storeError = nil;
							if (![supervoteClient updateElection:electionObj withObject:election withLastModified:lastModified withError:&storeError]) {
								if (storeError != nil) {
									LogError(@"Storage error while updating election '%@': %@", electionGuid, [storeError localizedDescription]);
								}
							}
						}
					}
				}
				/* handle NOT_FOUND and CLOSED the same way */
				else if (status == ES_NOT_FOUND || status == ES_CLOSED) { 
					if (electionObj != nil) {
						if (status == ES_NOT_FOUND) {
							LogWarn(@"Election '%@' not found at the server, but exists locally?", electionGuid);
						}
						
						if ([electionObj.status boolValue]) {
							LogInfo(@"Closing election '%@'", electionGuid);
							
							electionObj.status = [NSNumber numberWithBool:NO];							
							NSError *error = nil;
							if (![managedObjectContext_ save:&error]) {
								LogError(@"Storage error while setting status of election '%@' to closed: %@", electionGuid, [error userInfo]);
							}
						}
						else {
							LogInfo(@"Election '%@' up to date, no updates necessary", electionGuid);
						}
					}
					else {
						LogWarn(@"Election '%@' closed, but not stored locally?", electionGuid);
					}
				}
				else if (status == ES_NOT_MODIFIED) {
					/* nothing to do */
				}
			}
			else {
				LogInfo(@"Election '%@' up to date (%@), no updates necessary", electionGuid, electionObj.lastModified);
			}
			
			if (electionObj != nil) {
				NSArray *votes = [supervoteClient getVotesForBallot:electionGuid withLastUpdatedTime:electionObj.lastFriendUpdate];
				if (votes != nil) {
					NSDate *newUpdateTime = [supervoteClient insertVotes:votes];

					if (newUpdateTime != nil && (electionObj.lastFriendUpdate == nil || [electionObj.lastFriendUpdate timeIntervalSinceDate:newUpdateTime] <= -1.0)) {
						LogDebug(@"Updating last friend vote to %@ for election %@", newUpdateTime, electionObj.guid);
						NSError *error = nil;
						
						electionObj.lastFriendUpdate = newUpdateTime;
						if (![managedObjectContext_ save:&error]) {
							LogError(@"Storage error while setting lastFriendUpdate of election '%@' to %@: %@", electionGuid, electionObj.lastFriendUpdate, error);
						}
					}
				}
			}
		}
	}
	
	runningUpdate = NO;
}

/* http://stackoverflow.com/questions/3869217/iphone-ios-running-in-separate-thread */
- (void)updateDataAsynchronously:(BOOL)withAlerts withDelegate:(id)delegate {
	dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// Add code here to do background processing
		//
		//
		[self updateData:withAlerts];

		dispatch_async( dispatch_get_main_queue(), ^{
			// Add code here to update the UI/send notifications based on the
			// results of the background processing
			if (delegate != nil && [delegate respondsToSelector:@selector(doneWithUpdateData)]) {
				[delegate performSelector:@selector(doneWithUpdateData)];
			}
		});
	});
}


#pragma mark -
#pragma mark Custom actions

- (void)deleteFacebookPhotos {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	
	NSString *fbDir = [NSString stringWithFormat:@"%@/facebook", documentsPath];
	
	NSError *error = nil;
	if ([manager fileExistsAtPath:fbDir] && ![manager removeItemAtPath:fbDir error:&error]) {
		LogError(@"Error while deleting facebook directory: %@", [error localizedDescription]);
	}
}

- (void)switchToMainApp:(UIView *)currentView {
	if (mainAppController == nil)
	{
//		if (_facebookClient.loggedIn) {
//			LogInfo(@"Already logged into Facebook, updating friends");
//			[_facebookClient updateFriends];
//		}
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults objectForKey:@"ShowedTutorial"] == nil) {
			QuickTutorialViewController *controller = [[QuickTutorialViewController alloc] initWithNibName:@"QuickTutorialViewController" bundle:[NSBundle mainBundle]];
			
			self.window.rootViewController = controller;
			[controller release];
		}
		else if ([defaults objectForKey:@"FacebookAlert"] == nil) {
			FacebookIntegrationViewController *fbController = [[FacebookIntegrationViewController alloc] initWithNibName:@"FacebookIntegrationViewController" bundle:[NSBundle mainBundle]];
			fbController.facebookClient = self.facebookClient;
			fbController.client = self.supervoteClient;
			
			if (currentView == nil) {
				self.window.rootViewController = fbController;
			}
			else {
				self.window.rootViewController = fbController;
				/* TODO: can't get this transition to work without it being shifted up 20px */
				/* maybe its okay though, too many transitions already? */
//				[UIView transitionFromView:currentView
//									toView:fbController.view
//								  duration:0.65f
//								   options:UIViewAnimationOptionTransitionFlipFromRight
//								completion:^(BOOL finished) {/*self.window.rootViewController = fbController;*/}];
//				self.window.rootViewController = fbController;
			}
			[fbController release];
		}		else {
			UITabBarController *tabBarController = [[UITabBarController alloc] init];
			self.mainAppController = tabBarController;

			//		FeedController *feeds = [[[FeedController alloc] initWithNibName:@"FeedController" bundle:[NSBundle mainBundle]] autorelease];
			//		feeds.title = @"Feed";
			//		feeds.tabBarItem.image = [UIImage imageNamed:@"users.png"];
			//		feeds.managedObjectContext = self.managedObjectContext;
			//		feeds.client = self.supervoteClient;
			
			ListElectionsController *elections = [[[ListElectionsController alloc] initWithNibName:@"ListElections" bundle:[NSBundle mainBundle]] autorelease];
			elections.title = NSLocalizedString(@"MyBallots", nil);
			elections.tabBarItem.image = [UIImage imageNamed:@"check-64.png"];
			elections.managedObjectContext = self.managedObjectContext;
			elections.client = self.supervoteClient;
			UINavigationController *electionNavigation = [[[UINavigationController alloc] initWithRootViewController:elections] autorelease];
			
			SettingsController *settings = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:[NSBundle mainBundle]];
			settings.title = NSLocalizedString(@"Advanced", nil);
			settings.managedObjectContext = self.managedObjectContext;
			settings.client = self.supervoteClient;
			settings.facebookClient = self.facebookClient;
			
			VoterRegistrationViewController *registration = [[VoterRegistrationViewController alloc] initWithNibName:@"VoterRegistrationViewController" bundle:[NSBundle mainBundle]];
			registration.title = NSLocalizedString(@"Registration", nil);
			registration.context = self.managedObjectContext;
			registration.client = self.supervoteClient;
			
			/* http://redartisan.com/2010/6/27/uisegmented-control-view-switching-revisited */
			NSArray *viewControllers = [NSArray arrayWithObjects:registration, settings, nil];
			[settings release];
			[registration release];
			
			UINavigationController *navigationController = [[UINavigationController alloc] init];
			navigationController.title = NSLocalizedString(@"Settings", nil);
			navigationController.tabBarItem.image = [UIImage imageNamed:@"advanced.png"];
			
			segmentsController = [[SegmentsController alloc] initWithNavigationController:navigationController viewControllers:viewControllers];
			segmentedControl = [[UISegmentedControl alloc] initWithItems:[viewControllers arrayByPerformingSelector:@selector(title)]];
			segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
			
			[segmentedControl addTarget:segmentsController
								 action:@selector(indexDidChangeForSegmentedControl:)
					   forControlEvents:UIControlEventValueChanged];
			
			segmentedControl.selectedSegmentIndex = 0;
			[segmentsController indexDidChangeForSegmentedControl:segmentedControl];
			
			AboutUsViewController *aboutUs = [[AboutUsViewController alloc] initWithNibName:@"AboutUsViewController" bundle:[NSBundle mainBundle]];
			aboutUs.title = NSLocalizedString(@"ContactUs", nil);
			aboutUs.tabBarItem.image = [UIImage imageNamed:@"comment.png"];
			
			[tabBarController setViewControllers:[[[NSArray alloc] initWithObjects:electionNavigation, navigationController, aboutUs, nil] autorelease]];
			[navigationController release];
			[aboutUs release];
			
			//if (currentView == nil) {
				self.window.rootViewController = tabBarController;
			//}
//			else {
//				// http://stackoverflow.com/questions/5279313/is-there-a-way-to-change-views-in-ios-without-using-uinavigationcontroller		
//				/* http://stackoverflow.com/questions/8146253/animate-change-of-view-controllers-without-using-navigation-controller-stack-su */
//				/* http://developer.apple.com/library/ios/#documentation/uikit/reference/uiview_class/uiview/uiview.html */
//				[UIView transitionFromView:currentView
//									toView:tabBarController.view
//								duration:0.65f
//								   options:UIViewAnimationOptionTransitionFlipFromRight
//								completion:^(BOOL finished) {self.window.rootViewController = tabBarController;}];
//				
//				self.window.rootViewController = tabBarController;
//			}
			
			[tabBarController release];
		}
	}
	else {
		// http://blog.evandavey.com/2008/12/how-to-jump-between-tabs-using-uitabbarcontroller.html
		mainAppController.selectedIndex = 0;
		[mainAppController.selectedViewController viewDidAppear:YES];
		self.window.rootViewController = mainAppController;
	}

}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Supervote" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	
    return managedObjectModel_;
}

- (void)deletePersistentStoreCoordinator {
	NSArray *stores = [persistentStoreCoordinator_ persistentStores];
	self.mainAppController = nil;
	// http://stackoverflow.com/questions/1077810/delete-reset-all-entries-in-core-data
	for(NSPersistentStore *store in stores) {
		[persistentStoreCoordinator_ removePersistentStore:store error:nil];
		LogInfo(@"Deleting persistence store: %@", store.URL.path);
		[[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
	}

	[self addDefaultPersistentStore];
}

- (void)addDefaultPersistentStore {
	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Supervote.sqlite"];
	LogInfo(@"Adding persistent store: %@", storeURL);
    
    NSError *error = nil;
	if (persistentStoreCoordinator_ == nil) {
		persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	}
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType
												   configuration:nil
															 URL:storeURL
														 options:options
														   error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        LogError(@"Unresolved error %@", [error localizedDescription]);
        abort();
    } 
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
	[self addDefaultPersistentStore];
    
    return persistentStoreCoordinator_;
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
	[mainAppController release];
    mainAppController = nil;
}

- (void)dealloc {
	if (_lastRefreshDate != nil) {
		[_lastRefreshDate release];
		_lastRefreshDate = nil;
	}
	self.supervoteClient = nil;
	self.facebookClient = nil;
	[managedObjectContext_ release];
	[managedObjectModel_ release];
	if (persistentStoreCoordinator_ != nil) {
		[persistentStoreCoordinator_ release];
	}
	self.viewController = nil;
	self.mainAppController = nil;
	self.segmentsController = nil;
	self.segmentedControl = nil;
    [window release];
    [super dealloc];
}


@end
