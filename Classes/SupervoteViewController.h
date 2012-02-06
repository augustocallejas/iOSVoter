//
//  SupervoteViewController.h
//  Supervote
//
//  Created by augusto callejas on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SupervoteClient.h"

@interface SupervoteViewController : UIViewController <UITextFieldDelegate> {
	UILabel *_leftLabel;
	UILabel *_rightLabel;
	UITextField *FirstZIPField;
	UITextField *SecondZIPField;
	UIButton *joinButton;
	//UITabBarController *mainAppController;
	NSMutableData *responseData;
@private
	SupervoteClient *_client;
}

@property (nonatomic, retain) IBOutlet UILabel *leftLabel;
@property (nonatomic, retain) IBOutlet UILabel *rightLabel;
@property (nonatomic, retain) IBOutlet UITextField *FirstZIPField;
@property (nonatomic, retain) IBOutlet UITextField *SecondZIPField;
@property (nonatomic, retain) IBOutlet UIButton	*joinButton;
//@property (nonatomic, retain) IBOutlet UITabBarController *mainAppController;
@property (nonatomic, retain) SupervoteClient *client;

- (IBAction)doTermsOfService;
- (IBAction)doCopyrightButton;
- (IBAction)doJoinButtonSendZip;

@end

