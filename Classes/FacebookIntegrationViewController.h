//
//  FacebookIntegrationViewController.h
//  Supervote
//
//  Created by augusto callejas on 1/29/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "FacebookClient.h"
#import "SupervoteClient.h"

@interface FacebookIntegrationViewController : UIViewController <FBSessionDelegate> {

@private
	UILabel *_titleLabel;
	SupervoteClient *_client;
	FacebookClient *_facebookClient;
}

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UITextView *facebookMessage;
@property(nonatomic, retain) SupervoteClient *client;
@property(nonatomic, retain) FacebookClient *facebookClient;
@property(nonatomic, retain) IBOutlet UIButton *facebookLoginButton;
@property(nonatomic, retain) IBOutlet UIButton *noThanksButton;

- (IBAction)doYesFacebookIntegration;
- (IBAction)doNoFacebookIntegration;

@end
