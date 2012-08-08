//
//  CandidateViewCell.h
//  Supervote
//
//  Created by augusto callejas on 9/27/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EndorsementButton.h"

@interface CandidateViewCell : UITableViewCell {
@private	
	IBOutlet UILabel *_candidateName;
	IBOutlet UILabel *_partyName;
//	IBOutlet UIImageView *_candidateIcon;
	IBOutlet EndorsementButton *_friendIcon1;
	IBOutlet EndorsementButton *_friendIcon2;
	IBOutlet EndorsementButton *_friendIcon3;
	IBOutlet EndorsementButton *_friendIcon4;
	IBOutlet EndorsementButton *_friendIcon5;
	IBOutlet EndorsementButton *_friendIcon6;
	IBOutlet EndorsementButton *_friendIcon7;
	IBOutlet UIButton *_viewAllEndorsements;
	IBOutlet UIButton *_editEndorsement;
	IBOutlet UIButton *_voteCandidate;
	IBOutlet UIImageView *_voteStatus;
	IBOutlet UIImageView *_votePrivate;
}

@property (nonatomic, retain) UILabel *candidateName;
@property (nonatomic, retain) UILabel *partyName;
//@property (nonatomic, retain) UIImageView *candidateIcon;
@property (nonatomic, retain) EndorsementButton *friendIcon1;
@property (nonatomic, retain) EndorsementButton *friendIcon2;
@property (nonatomic, retain) EndorsementButton *friendIcon3;
@property (nonatomic, retain) EndorsementButton *friendIcon4;
@property (nonatomic, retain) EndorsementButton *friendIcon5;
@property (nonatomic, retain) EndorsementButton *friendIcon6;
@property (nonatomic, retain) EndorsementButton *friendIcon7;
@property (nonatomic, retain) UIButton *viewAllEndorsements;
@property (nonatomic, retain) UIButton *editEndorsement;
@property (nonatomic, retain) UIButton *voteCandidate;
@property (nonatomic, retain) UIImageView *voteStatus;
@property (nonatomic, retain) UIImageView *votePrivate;

- (void)toggleDeleteButton;

@end
