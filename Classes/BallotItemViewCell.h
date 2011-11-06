//
//  PositionViewCell.h
//  Supervote
//
//  Created by augusto callejas on 9/11/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EndorsementButton.h"

@interface BallotItemViewCell : UITableViewCell {
	IBOutlet UILabel *_majorTitle;
	IBOutlet UILabel *_minorTitle;
	IBOutlet EndorsementButton *_friendButton1;
	IBOutlet EndorsementButton *_friendButton2;
	IBOutlet EndorsementButton *_friendButton3;
	IBOutlet EndorsementButton *_friendButton4;
	IBOutlet EndorsementButton *_friendButton5;
	IBOutlet EndorsementButton *_friendCount;
}

@property (nonatomic, retain) UILabel *majorTitle;
@property (nonatomic, retain) UILabel *minorTitle;
@property (nonatomic, retain) EndorsementButton *friendButton1;
@property (nonatomic, retain) EndorsementButton *friendButton2;
@property (nonatomic, retain) EndorsementButton *friendButton3;
@property (nonatomic, retain) EndorsementButton *friendButton4;
@property (nonatomic, retain) EndorsementButton *friendButton5;
@property (nonatomic, retain) EndorsementButton *friendCount;

@end
