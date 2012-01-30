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
	SupervoteClient *_client;
	FacebookClient *_facebookClient;
}

@property(nonatomic, retain) SupervoteClient *client;
@property(nonatomic, retain) FacebookClient *facebookClient;
@property(nonatomic, retain) IBOutlet UIButton *facebookLoginButton;

- (IBAction)doYesFacebookIntegration;
- (IBAction)doNoFacebookIntegration;

@end
