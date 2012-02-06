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
	IBOutlet UITableViewCell *_privacyCell1;
	IBOutlet UITableViewCell *_privacyCell2;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) UITableViewCell *privacyCell1;
@property (nonatomic, retain) UITableViewCell *privacyCell2;

- (IBAction)doShowBallots;

@end
