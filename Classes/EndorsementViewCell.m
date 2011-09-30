//
//  EndorsementViewCell.m
//  Supervote
//
//  Created by augusto callejas on 9/28/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "EndorsementViewCell.h"


@implementation EndorsementViewCell

@synthesize endorserIcon = _endorserIcon;
@synthesize endorsementStatement = _endorsementStatement;

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
	self.endorsementStatement = nil;
    [super dealloc];
}


@end
