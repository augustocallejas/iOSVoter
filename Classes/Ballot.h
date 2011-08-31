//
//  Ballot.h
//  Supervote
//
//  Created by augusto callejas on 8/31/11.
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
@property (nonatomic, retain) NSSet* measures;

@end


@interface Ballot (CoreDataGeneratedAccessors)
- (void)addVotesObject:(BallotVote *)value;
- (void)removeVotesObject:(BallotVote *)value;
- (void)addVotes:(NSSet *)value;
- (void)removeVotes:(NSSet *)value;

- (void)addMeasuresObject:(NSManagedObject *)value;
- (void)removeMeasuresObject:(NSManagedObject *)value;
- (void)addMeasures:(NSSet *)value;
- (void)removeMeasures:(NSSet *)value;

@end

