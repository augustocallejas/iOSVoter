//
//  QuickTutorialViewController.h
//  Supervote
//
//  Created by augusto callejas on 1/30/12.
//  Copyright 2012 Canary Falls Software LLC. All rights reserved.
//



@interface QuickTutorialViewController : UIViewController {
	
@private
	UILabel *_titleLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UITextView *paragraph1;
@property (nonatomic, retain) IBOutlet UITableViewCell *privacyCell1;
@property (nonatomic, retain) IBOutlet UILabel *privacyLabel1;
@property (nonatomic, retain) IBOutlet UITextView *paragraph2;
@property (nonatomic, retain) IBOutlet UITableViewCell *privacyCell2;
@property (nonatomic, retain) IBOutlet UILabel *privacyLabel2;
@property (nonatomic, retain) IBOutlet UIButton *button;

- (IBAction)doShowBallots;

@end
