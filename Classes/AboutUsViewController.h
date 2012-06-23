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
}

@property(nonatomic, retain) IBOutlet UILabel *leftLabel;
@property(nonatomic, retain) IBOutlet UILabel *rightLabel;
@property(nonatomic, retain) IBOutlet UITextView *descriptionText;
@property(nonatomic, retain) IBOutlet UIButton *emailUsButton;
@property(nonatomic, retain) IBOutlet UIButton *facebookUsButton;
@property(nonatomic, retain) IBOutlet UIButton *twitterUsButton;
@property(nonatomic, retain) IBOutlet UIButton *tosButton;
@property(nonatomic, retain) IBOutlet UIButton *privacyButton;
@property(nonatomic, retain) IBOutlet UILabel *iconsFromLabel;

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
