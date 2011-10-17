//
//  PositionViewCell.m
//  Supervote
//
//  Created by augusto callejas on 9/11/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "BallotItemViewCell.h"


@implementation BallotItemViewCell

@synthesize majorTitle = _majorTitle;
@synthesize minorTitle = _minorTitle;
@synthesize friendButton1 = _friendButton1;
@synthesize friendButton2 = _friendButton2;
@synthesize friendButton3 = _friendButton3;
@synthesize friendButton4 = _friendButton4;
@synthesize friendButton5 = _friendButton5;
@synthesize friendButton6 = _friendButton6;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
