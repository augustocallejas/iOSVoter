//
//  SettingsController.h
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//

#import "FacebookClient.h"
#import "SupervoteClient.h"


@interface SettingsController : UIViewController <FBSessionDelegate, UIActionSheetDelegate> {
	
@private
	NSManagedObjectContext *_managedObjectContext;
	NSString *_documentsPath;
	SupervoteClient *_client;
	FacebookClient *_facebookClient;
	
	UILabel *_facebookLabel;
	UILabel *_accountLabel;
	UILabel *_supportLabel;
}

@property(nonatomic, retain) IBOutlet UILabel *facebookLabel;
@property(nonatomic, retain) IBOutlet UILabel *accountLabel;
@property(nonatomic, retain) IBOutlet UILabel *supportLabel;

@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) SupervoteClient *client;
@property(nonatomic, retain) FacebookClient *facebookClient;
@property(nonatomic, retain) NSString *documentsPath;
@property(nonatomic, retain) IBOutlet UIButton *facebookLoginButton;

- (IBAction)doFacebookLogin;
- (IBAction)doResetApplication;

@end
