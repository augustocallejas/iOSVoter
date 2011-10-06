//
//  CandidateViewCell.h
//  Supervote
//
//  Created by augusto callejas on 9/27/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CandidateViewCell : UITableViewCell {
@private	
	IBOutlet UILabel *_candidateName;
	IBOutlet UILabel *_partyName;
	IBOutlet UIImageView *_candidateIcon;
	IBOutlet UIImageView *_topFriendIcon;
	IBOutlet UILabel *_topEndorsement;
	IBOutlet UIImageView *_friendIcon1;
	IBOutlet UILabel *_friendEndorsement1;
	IBOutlet UIImageView *_friendIcon2;
	IBOutlet UILabel *_friendEndorsement2;
	IBOutlet UIButton *_viewAllEndorsements;
	IBOutlet UIButton *_voteCandidate;
	IBOutlet UIImageView *_voteStatus;
}

@property (nonatomic, retain) UILabel *candidateName;
@property (nonatomic, retain) UILabel *partyName;
@property (nonatomic, retain) UIImageView *candidateIcon;
@property (nonatomic, retain) UIImageView *topFriendIcon;
@property (nonatomic, retain) UILabel *topEndorsement;
@property (nonatomic, retain) UIImageView *friendIcon1;
@property (nonatomic, retain) UILabel *friendEndorsement1;
@property (nonatomic, retain) UIImageView *friendIcon2;
@property (nonatomic, retain) UILabel *friendEndorsement2;
@property (nonatomic, retain) UIButton *viewAllEndorsements;
@property (nonatomic, retain) UIButton *voteCandidate;
@property (nonatomic, retain) UIImageView *voteStatus;

@end
