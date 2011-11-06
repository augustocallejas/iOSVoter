//
//  ViewEndorsementController.h
//  Supervote
//
//  Created by augusto callejas on 11/5/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FriendBallotVote.h"

@interface ViewEndorsementController : UIViewController {

@private
	FriendBallotVote *_ballotVote;
	UILabel *_friendLabel;
	UITextView *_endorsementStatement;
	UILabel *_candidateName;
}

@property (nonatomic, retain) FriendBallotVote *ballotVote;
@property (nonatomic, retain) IBOutlet UILabel *friendLabel;
@property (nonatomic, retain) IBOutlet UITextView *endorsementStatement;
@property (nonatomic, retain) IBOutlet UILabel *candidateName;


@end
