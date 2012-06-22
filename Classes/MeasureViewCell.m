//
//  MeasureViewCell.m
//  Supervote
//
//  Created by augusto callejas on 10/9/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "MeasureViewCell.h"


@implementation MeasureViewCell

@synthesize measureName = _measureName;
@synthesize friendIcon1 = _friendIcon1;
@synthesize friendIcon2 = _friendIcon2;
@synthesize friendIcon3 = _friendIcon3;
@synthesize friendIcon4 = _friendIcon4;
@synthesize friendIcon5 = _friendIcon5;
@synthesize friendIcon6 = _friendIcon6;
@synthesize friendIcon7 = _friendIcon7;
@synthesize viewAllEndorsements = _viewAllEndorsements;
@synthesize editEndorsement = _editEndorsement;
@synthesize	voteMeasure = _voteMeasure;
@synthesize deleteVote;
@synthesize voteStatus = _voteStatus;
@synthesize votePrivate = _votePrivate;

+ (NSString *)voteToString:(NSNumber *)vote {
	if (vote == nil) {
		return NSLocalizedString(@"Undecided", nil);
	}
	else if ([vote boolValue]) {
		return NSLocalizedString(@"YES", nil);
	}
	
	return NSLocalizedString(@"NO", nil);
}

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

- (void)toggleDeleteButton {
	if (deleteVote.hidden) {
		deleteVote.hidden = NO;
	}
	else {
		deleteVote.hidden = YES;
	}
}


- (void)dealloc {
    [super dealloc];
}


@end
