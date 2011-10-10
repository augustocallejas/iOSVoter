//
//  MeasureViewCell.h
//  Supervote
//
//  Created by augusto callejas on 10/9/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

@interface MeasureViewCell : UITableViewCell {
@private
	IBOutlet UILabel *_measureName;
	IBOutlet UIImageView *_friendIcon1;
	IBOutlet UILabel *_friendEndorsement1;
	IBOutlet UIImageView *_friendIcon2;
	IBOutlet UILabel *_friendEndorsement2;
	IBOutlet UIImageView *_friendIcon3;
	IBOutlet UILabel *_friendEndorsement3;
	IBOutlet UIButton *_viewAllEndorsements;
	IBOutlet UIButton *_voteMeasure;
	IBOutlet UIImageView *_voteStatus;
}

@property (nonatomic, retain) UILabel *measureName;
@property (nonatomic, retain) UIImageView *friendIcon1;
@property (nonatomic, retain) UILabel *friendEndorsement1;
@property (nonatomic, retain) UIImageView *friendIcon2;
@property (nonatomic, retain) UILabel *friendEndorsement2;
@property (nonatomic, retain) UIImageView *friendIcon3;
@property (nonatomic, retain) UILabel *friendEndorsement3;
@property (nonatomic, retain) UIButton *viewAllEndorsements;
@property (nonatomic, retain) UIButton *voteMeasure;
@property (nonatomic, retain) UIImageView *voteStatus;

@end
