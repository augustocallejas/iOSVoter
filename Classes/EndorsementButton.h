//
//  EndorsementButton.h
//  Supervote
//
//  Created by augusto callejas on 11/6/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "FriendBallotVote.h"
#import "FriendMeasureVote.h"

@interface EndorsementButton : UIButton {

@private
	FriendBallotVote *_ballotVote;
	FriendMeasureVote *_measureVote;
}

@property (nonatomic, retain) FriendBallotVote *ballotVote;
@property (nonatomic, retain) FriendMeasureVote *measureVote;

@end
