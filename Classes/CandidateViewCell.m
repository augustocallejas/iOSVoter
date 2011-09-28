//
//  CandidateViewCell.m
//  Supervote
//
//  Created by augusto callejas on 9/27/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "CandidateViewCell.h"


@implementation CandidateViewCell

@synthesize candidateName = _candidateName;
@synthesize partyName = _partyName;
@synthesize candidateIcon = _candidateIcon;
@synthesize endorsementCount = _endorsementCount;
@synthesize topFriendIcon = _topFriendIcon;
@synthesize topEndorsement = _topEndorsement;
@synthesize friendIcon1 = _friendIcon1;
@synthesize friendIcon2 = _friendIcon2;
@synthesize friendIcon3 = _friendIcon3;
@synthesize friendIcon4 = _friendIcon4;
@synthesize friendIcon5 = _friendIcon5;
@synthesize friendIcon6 = _friendIcon6;
@synthesize viewAllEndorsements = _viewAllEndorsements;

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
