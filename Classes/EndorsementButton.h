//
//  EndorsementButton.h
//  Supervote
//
//  Created by augusto callejas on 11/6/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "FriendBallotVote.h"

@interface EndorsementButton : UIButton {

@private
	FriendBallotVote* _ballotVote;
}

@property (nonatomic, retain) FriendBallotVote *ballotVote;

@end
