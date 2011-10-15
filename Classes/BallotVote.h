//
//  BallotVote.h
//  Supervote
//
//  Created by augusto callejas on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Ballot;
@class Candidate;
@class Position;

@interface BallotVote :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * statement;
@property (nonatomic, retain) NSNumber * viewableByFriends;
@property (nonatomic, retain) Position * forPosition;
@property (nonatomic, retain) Ballot * forBallot;
@property (nonatomic, retain) Candidate * forCandidate;

@end



