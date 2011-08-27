//
//  BallotVote.h
//  Supervote
//
//  Created by augusto callejas on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Candidate;
@class Position;

@interface BallotVote :  NSManagedObject  
{
}

@property (nonatomic, retain) NSManagedObject * forBallot;
@property (nonatomic, retain) Position * forPosition;
@property (nonatomic, retain) Candidate * forCandidate;

@end



