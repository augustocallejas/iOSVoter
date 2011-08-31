//
//  BallotVote.h
//  Supervote
//
//  Created by augusto callejas on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Ballot;
@class Candidate;
@class Position;

@interface BallotVote :  NSManagedObject  
{
}

@property (nonatomic, retain) Ballot * forBallot;
@property (nonatomic, retain) Position * forPosition;
@property (nonatomic, retain) Candidate * forCandidate;

@end



