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
}

@property (nonatomic, retain) UILabel *positionTitle;
@property (nonatomic, retain) UILabel *candidateName;
@property (nonatomic, retain) UIImageView *candidateIcon;

@end
