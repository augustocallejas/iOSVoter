//
//  FacebookIntegrationViewController.h
//  Supervote
//
//  Created by augusto callejas on 1/29/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import "FacebookClient.h"

@interface FacebookIntegrationViewController : UIViewController <FBSessionDelegate> {

@private
	FacebookClient *_facebookClient;
}

@property(nonatomic, retain) FacebookClient *facebookClient;

- (IBAction)doYesFacebookIntegration;
- (IBAction)doNoFacebookIntegration;

@end
