//
//  PositionViewCell.m
//  Supervote
//
//  Created by augusto callejas on 9/11/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "PositionViewCell.h"


@implementation PositionViewCell

@synthesize positionTitle = _positionTitle;
@synthesize candidateName = _candidateName;
@synthesize candidateIcon = _candidateIcon;
@synthesize friendIcon1 = _friendIcon1;
@synthesize friendIcon2 = _friendIcon2;
@synthesize friendIcon3 = _friendIcon3;
@synthesize friendIcon4 = _friendIcon4;
@synthesize friendIcon5 = _friendIcon5;
@synthesize friendIcon6 = _friendIcon6;

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
