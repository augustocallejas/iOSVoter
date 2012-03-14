//
//  AboutUsViewController.h
//  Supervote
//
//  Created by augusto callejas on 3/13/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIWebViewController.h"

@interface AboutUsViewController : UIViewController <UIWebViewControllerDelegate> {

@private
	UILabel *_aboutUsLabel;
}

@property(nonatomic, retain) IBOutlet UILabel *aboutUsLabel;

- (void)didDismissModalView;
- (IBAction)doEmailUs;
- (IBAction)doFacebook;
- (IBAction)doTwitter;
- (IBAction)doTermsOfService;
- (IBAction)doPrivacy;
- (IBAction)doGotoQuiz;
- (IBAction)doIconDrawer;
- (IBAction)doFatCow;

@end
