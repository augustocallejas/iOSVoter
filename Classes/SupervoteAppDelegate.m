//
//  SupervoteAppDelegate.m
//  Supervote
//
//  Created by augusto callejas on 8/2/11.
//  Copyright 2011 Canary Falls LLC. All rights reserved.
//

#import "ListElectionsController.h"
#import "FeedController.h"
#import "SettingsController.h"
#import "SupervoteAppDelegate.h"
#import "SupervoteViewController.h"

@implementation SupervoteAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize mainAppController;
@synthesize facebook = _facebook;

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if (_facebook != nil) {
		return [_facebook handleOpenURL:url];
	}
	
	return NO;
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

	// Set the view controller as the window's root view controller and display.
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
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
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Custom actions

- (IBAction)doJoinButtonSendZip {
	if (mainAppController == nil)
	{
		//[[NSBundle mainBundle] loadNibNamed:@"MainApp" owner:self options:nil];

		self.mainAppController = [[[UITabBarController alloc] init] autorelease];
		//self.mainAppController.delegate = self;
		
		FeedController *feeds = [[[FeedController alloc] initWithNibName:@"FeedController" bundle:[NSBundle mainBundle]] autorelease];
		feeds.title = @"Feed";
		feeds.tabBarItem.image = [UIImage imageNamed:@"users.png"];
		
		
		ListElectionsController *elections = [[[ListElectionsController alloc] initWithNibName:@"ElectionsController" bundle:[NSBundle mainBundle]] autorelease];
		elections.title = @"Elections";
		elections.tabBarItem.image = [UIImage imageNamed:@"users.png"];
		elections.managedObjectContext = self.managedObjectContext;
		UINavigationController *electionNavigation = [[[UINavigationController alloc] initWithRootViewController:elections] autorelease];
//		[electionNavigation setNavigationBarHidden:YES];

		SettingsController *settings = [[[SettingsController alloc] initWithNibName:@"SettingsController" bundle:[NSBundle mainBundle]] autorelease];
		settings.title = @"Settings";
		settings.tabBarItem.image = [UIImage imageNamed:@"users.png"];
		self.facebook = settings.facebook;
		
		self.mainAppController.viewControllers = [[[NSArray alloc] initWithObjects:feeds, electionNavigation, settings, nil] autorelease];
		
		// TODO: not sure if this is the proper way to switch from one controller to another.
		// http://stackoverflow.com/questions/5279313/is-there-a-way-to-change-views-in-ios-without-using-uinavigationcontroller
		self.window.rootViewController = [self mainAppController];
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
	managedObjectModel_ = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
	
	return managedObjectModel_;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Supervote.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
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
	self.facebook = nil;
	[managedObjectContext_ release];
	[managedObjectModel_ release];
	[persistentStoreCoordinator_ release];
	
    [viewController release];
	if (mainAppController != nil)
	{
		[mainAppController release];
	}
    [window release];
    [super dealloc];
}


@end
