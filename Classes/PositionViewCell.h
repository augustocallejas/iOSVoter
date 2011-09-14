//
//  PositionViewCell.h
//  Supervote
//
//  Created by augusto callejas on 9/11/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PositionViewCell : UITableViewCell {
	IBOutlet UILabel *_positionTitle;
	IBOutlet UILabel *_candidateName;
	IBOutlet UIImageView *_candidateIcon;
	IBOutlet UIImageView *_friendIcon1;
	IBOutlet UIImageView *_friendIcon2;
	IBOutlet UIImageView *_friendIcon3;
	IBOutlet UIImageView *_friendIcon4;
	IBOutlet UIImageView *_friendIcon5;
	IBOutlet UIImageView *_friendIcon6;
}

@property (nonatomic, retain) UILabel *positionTitle;
@property (nonatomic, retain) UILabel *candidateName;
@property (nonatomic, retain) UIImageView *candidateIcon;
@property (nonatomic, retain) UIImageView *friendIcon1;
@property (nonatomic, retain) UIImageView *friendIcon2;
@property (nonatomic, retain) UIImageView *friendIcon3;
@property (nonatomic, retain) UIImageView *friendIcon4;
@property (nonatomic, retain) UIImageView *friendIcon5;
@property (nonatomic, retain) UIImageView *friendIcon6;

@end
