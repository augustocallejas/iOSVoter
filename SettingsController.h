//
//  SettingsController.h
//  Supervote
//
//  Created by augusto callejas on 8/4/11.
//  Copyright 2011 Supervote, LLC. All rights reserved.
//

#import "FacebookClient.h"
#import "SupervoteClient.h"


@interface SettingsController : UIViewController <UIActionSheetDelegate> {
	
@private
	NSString *_documentsPath;
	SupervoteClient *_client;
	FacebookClient *_facebookClient;
	
	UILabel *_facebookLabel;
}

@property(nonatomic, retain) IBOutlet UILabel *facebookLabel;
@property(nonatomic, retain) IBOutlet UIButton *facebookLoginButton;
@property(nonatomic, retain) IBOutlet UILabel *advancedLabel;
@property(nonatomic, retain) IBOutlet UIButton *resetAppButton;

@property(nonatomic, retain) SupervoteClient *client;
@property(nonatomic, retain) FacebookClient *facebookClient;

- (IBAction)doFacebookLogin;
- (IBAction)doResetApplication;

@end
