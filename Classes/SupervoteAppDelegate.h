//
//  SupervoteAppDelegate.h
//  Supervote
//
//  Created by augusto callejas on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


@class SupervoteViewController;

@interface SupervoteAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SupervoteViewController *viewController;
	UITabBarController *mainAppController;
	
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SupervoteViewController *viewController;
@property (nonatomic, retain) IBOutlet UITabBarController *mainAppController;

// http://www.cimgf.com/2011/01/07/passing-around-a-nsmanagedobjectcontext-on-the-iphone/
// http://www.cimgf.com/2011/06/02/saving-json-to-core-data/
// http://wiresareobsolete.com/wordpress/2009/12/adding-core-data-existing-iphone-projects/

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
- (IBAction)doJoinButtonSendZip;

@end

