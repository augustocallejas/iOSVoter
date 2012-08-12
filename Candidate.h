//
//  Candidate.h
//  Supervote
//
//  Created by augusto callejas on 8/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class BallotVote;
@class FriendBallotVote;
@class PoliticalParty;
@class PositionToCandidate;

@interface Candidate :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* myVotes;
@property (nonatomic, retain) PositionToCandidate * position;
@property (nonatomic, retain) PoliticalParty * party;
@property (nonatomic, retain) NSSet* friendVotes;

@end


@interface Candidate (CoreDataGeneratedAccessors)
- (void)addMyVotesObject:(BallotVote *)value;
- (void)removeMyVotesObject:(BallotVote *)value;
- (void)addMyVotes:(NSSet *)value;
- (void)removeMyVotes:(NSSet *)value;

- (void)addFriendVotesObject:(FriendBallotVote *)value;
- (void)removeFriendVotesObject:(FriendBallotVote *)value;
- (void)addFriendVotes:(NSSet *)value;
- (void)removeFriendVotes:(NSSet *)value;

@end

