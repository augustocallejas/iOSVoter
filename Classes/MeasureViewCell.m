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
@synthesize friendEndorsement1 = _friendEndorsement1;
@synthesize friendIcon2 = _friendIcon2;
@synthesize friendEndorsement2 = _friendEndorsement2;
@synthesize friendIcon3 = _friendIcon3;
@synthesize friendEndorsement3 = _friendEndorsement3;
@synthesize viewAllEndorsements = _viewAllEndorsements;
@synthesize editEndorsement = _editEndorsement;
@synthesize	voteMeasure = _voteMeasure;
@synthesize voteStatus = _voteStatus;
@synthesize votePrivate = _votePrivate;

+ (NSString *)voteToString:(NSNumber *)vote {
	if (vote == nil) {
		return @"Undecided";
	}
	else if ([vote boolValue]) {
		return @"YES";
	}
	
	return @"NO";
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


- (void)dealloc {
    [super dealloc];
}


@end
