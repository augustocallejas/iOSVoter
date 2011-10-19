//
//  CreateEndorsementViewController.h
//  Supervote
//
//  Created by augusto callejas on 9/29/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "Candidate.h"
#import "Measure.h"

/*
 * Protocol that is implemented by VoteCandidateController and VoteMeasureController.
 * This allows them to save a vote on a candidate or measure with an optional endorsement statement.
 */
@protocol ModalViewControllerDelegate <NSObject>

- (void)didDismissModalView:(BOOL)withVote toCandidate:(Candidate *)candidate orMeasureVote:(NSNumber *)measureVote withOptionalStatement:(NSString *)statement andViewableByFriends:(BOOL)viewable;

@end

@interface CreateEndorsementViewController : UIViewController {
	id<ModalViewControllerDelegate> delegate;
@private
	Candidate *_candidate;
	Measure *_measure;
	NSNumber *_measureVote;
	NSString *_statement;
	BOOL _viewableByFriends;
	BOOL _isEditOfExisting;
	IBOutlet UINavigationItem *_navItem;
	IBOutlet UILabel *_endorsementTitle;
	IBOutlet UITextView *_textView;
	IBOutlet UITableViewCell *_viewableByFriendsCell;
	IBOutlet UIImageView *_privacyLock;
	IBOutlet UISwitch *_viewableByFriendsSwitch;
	IBOutlet UIBarButtonItem* _voteButton;
	IBOutlet UIBarButtonItem* _cancelButton;
}

@property (nonatomic, assign) id<ModalViewControllerDelegate> delegate;
@property (nonatomic, retain) Candidate *candidate;
@property (nonatomic, retain) Measure *measure;
@property (nonatomic, assign) NSNumber *measureVote;
@property (nonatomic, retain) NSString *statement;
@property (nonatomic, assign) BOOL viewableByFriends;
@property (nonatomic, assign) BOOL isEditOfExisting;
@property (nonatomic, retain) UINavigationItem *navItem;
@property (nonatomic, retain) UILabel *endorsementTitle;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UITableViewCell *viewableByFriendsCell;
@property (nonatomic, retain) UIImageView *privacyLock;
@property (nonatomic, retain) UISwitch *viewableByFriendsSwitch;
@property (nonatomic, retain) UIBarButtonItem* voteButton;
@property (nonatomic, retain) UIBarButtonItem* cancelButton;

- (IBAction)dismissView:(id)sender;
- (IBAction)switchedPrivacy:(id)sender;

@end
