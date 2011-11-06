//
//  EndorsementButton.m
//  Supervote
//
//  Created by augusto callejas on 11/6/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import "EndorsementButton.h"

@implementation EndorsementButton

@synthesize ballotVote = _ballotVote;

- (void)dealloc {
	self.ballotVote = nil;
    [super dealloc];
}

@end
