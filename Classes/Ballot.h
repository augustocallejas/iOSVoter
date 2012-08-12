//
//  Ballot.h
//  Supervote
//
//  Created by augusto callejas on 8/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class BallotVote;
@class Election;
@class MeasureVote;

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

- (void)addMeasuresObject:(MeasureVote *)value;
- (void)removeMeasuresObject:(MeasureVote *)value;
- (void)addMeasures:(NSSet *)value;
- (void)removeMeasures:(NSSet *)value;

@end

