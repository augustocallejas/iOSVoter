//
//  SupervoteAppDelegate.h
//  Supervote
//
//  Created by augusto callejas on 8/2/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "FacebookClient.h"
#import "SegmentsController.h"
#import "SupervoteClient.h"

extern NSString *const FBSessionStateChangedNotification;

@class SupervoteViewController;

@interface SupervoteAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
    UIWindow *window;
    SupervoteViewController *viewController;
	UITabBarController *mainAppController;
	
@private
	NSString *facebookAppURLScheme;
	BOOL runningUpdate;
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
	NSDate *_lastRefreshDate;
	PLCrashReport *_report;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) SupervoteViewController *viewController;
@property (nonatomic, retain) UITabBarController *mainAppController;

@property (nonatomic, retain) SegmentsController *segmentsController;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;

// http://www.cimgf.com/2011/01/07/passing-around-a-nsmanagedobjectcontext-on-the-iphone/
// http://www.cimgf.com/2011/06/02/saving-json-to-core-data/
// http://wiresareobsolete.com/wordpress/2009/12/adding-core-data-existing-iphone-projects/

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) SupervoteClient *supervoteClient;
@property (nonatomic, retain) FacebookClient *facebookClient;

@property (nonatomic, retain, readonly) NSDate *lastRefreshDate;

- (void)updateData:(BOOL)withAlerts;
- (void)updateDataAsynchronously:(BOOL)withAlerts withDelegate:(id)delegate;
- (void)deleteFacebookPhotos;
- (void)addDefaultPersistentStore;
- (void)deletePersistentStoreCoordinator;
- (void)switchToWelcomePage;
- (NSURL *)applicationDocumentsDirectory;
- (void)switchToMainApp:(UIView *)currentView;

@end

