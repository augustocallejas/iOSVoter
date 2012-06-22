//
//  MeasureViewCell.h
//  Supervote
//
//  Created by augusto callejas on 10/9/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "EndorsementButton.h"

@interface MeasureViewCell : UITableViewCell {
@private
	IBOutlet UILabel *_measureName;
	IBOutlet EndorsementButton *_friendIcon1;
	IBOutlet EndorsementButton *_friendIcon2;
	IBOutlet EndorsementButton *_friendIcon3;
	IBOutlet EndorsementButton *_friendIcon4;
	IBOutlet EndorsementButton *_friendIcon5;
	IBOutlet EndorsementButton *_friendIcon6;
	IBOutlet EndorsementButton *_friendIcon7;
	IBOutlet UIButton *_viewAllEndorsements;
	IBOutlet UIButton *_editEndorsement;
	IBOutlet UIButton *_voteMeasure;
	IBOutlet UIImageView *_voteStatus;
	IBOutlet UIImageView *_votePrivate;
}

@property (nonatomic, retain) UILabel *measureName;
@property (nonatomic, retain) EndorsementButton *friendIcon1;
@property (nonatomic, retain) EndorsementButton *friendIcon2;
@property (nonatomic, retain) EndorsementButton *friendIcon3;
@property (nonatomic, retain) EndorsementButton *friendIcon4;
@property (nonatomic, retain) EndorsementButton *friendIcon5;
@property (nonatomic, retain) EndorsementButton *friendIcon6;
@property (nonatomic, retain) EndorsementButton *friendIcon7;
@property (nonatomic, retain) UIButton *viewAllEndorsements;
@property (nonatomic, retain) UIButton *editEndorsement;
@property (nonatomic, retain) UIButton *voteMeasure;
@property (nonatomic, retain) IBOutlet UIButton *deleteVote;
@property (nonatomic, retain) UIImageView *voteStatus;
@property (nonatomic, retain) UIImageView *votePrivate;

+ (NSString *)voteToString:(NSNumber *)vote;
- (void)toggleDeleteButton;

@end
