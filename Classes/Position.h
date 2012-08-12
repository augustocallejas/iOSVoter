//
//  Position.h
//  Supervote
//
//  Created by augusto callejas on 8/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class BallotVote;
@class Election;
@class FriendBallotVote;
@class PositionToCandidate;

@interface Position :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * levelOrder;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * level;
@property (nonatomic, retain) NSNumber * titleOrder;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSSet* myVotes;
@property (nonatomic, retain) NSSet* candidates;
@property (nonatomic, retain) Election * forElection;
@property (nonatomic, retain) NSSet* friendVotes;

@end


@interface Position (CoreDataGeneratedAccessors)
- (void)addMyVotesObject:(BallotVote *)value;
- (void)removeMyVotesObject:(BallotVote *)value;
- (void)addMyVotes:(NSSet *)value;
- (void)removeMyVotes:(NSSet *)value;

- (void)addCandidatesObject:(PositionToCandidate *)value;
- (void)removeCandidatesObject:(PositionToCandidate *)value;
- (void)addCandidates:(NSSet *)value;
- (void)removeCandidates:(NSSet *)value;

- (void)addFriendVotesObject:(FriendBallotVote *)value;
- (void)removeFriendVotesObject:(FriendBallotVote *)value;
- (void)addFriendVotes:(NSSet *)value;
- (void)removeFriendVotes:(NSSet *)value;

@end

