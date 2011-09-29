//
//  EndorsementViewCell.h
//  Supervote
//
//  Created by augusto callejas on 9/28/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//


@interface EndorsementViewCell : UITableViewCell {
@private
	IBOutlet UIImageView *_endorserIcon;
	IBOutlet UILabel *_endorsementStatement;	
}

@property (nonatomic, retain) UIImageView *endorserIcon;
@property (nonatomic, retain) UILabel *endorsementStatement;

@end
