//
//  PositionViewCell.h
//  Supervote
//
//  Created by augusto callejas on 9/11/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BallotItemViewCell : UITableViewCell {
	IBOutlet UILabel *_majorTitle;
	IBOutlet UILabel *_minorTitle;
	IBOutlet UIButton *_friendButton1;
	IBOutlet UIButton *_friendButton2;
	IBOutlet UIButton *_friendButton3;
	IBOutlet UIButton *_friendButton4;
	IBOutlet UIButton *_friendButton5;
	IBOutlet UIButton *_friendCount;
}

@property (nonatomic, retain) UILabel *majorTitle;
@property (nonatomic, retain) UILabel *minorTitle;
@property (nonatomic, retain) UIButton *friendButton1;
@property (nonatomic, retain) UIButton *friendButton2;
@property (nonatomic, retain) UIButton *friendButton3;
@property (nonatomic, retain) UIButton *friendButton4;
@property (nonatomic, retain) UIButton *friendButton5;
@property (nonatomic, retain) UIButton *friendCount;

@end
