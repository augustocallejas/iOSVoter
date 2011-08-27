//
//  Ballot.h
//  Supervote
//
//  Created by augusto callejas on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class BallotVote;
@class Election;

@interface Ballot :  NSManagedObject  
{
}

@property (nonatomic, retain) Election * forElection;
@property (nonatomic, retain) NSSet* votes;

@end


@interface Ballot (CoreDataGeneratedAccessors)
- (void)addVotesObject:(BallotVote *)value;
- (void)removeVotesObject:(BallotVote *)value;
- (void)addVotes:(NSSet *)value;
- (void)removeVotes:(NSSet *)value;

@end

