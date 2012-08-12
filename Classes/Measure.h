//
//  Measure.h
//  Supervote
//
//  Created by augusto callejas on 8/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Election;
@class FriendMeasureVote;
@class MeasureVote;

@interface Measure :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * levelOrder;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * level;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * longDescription;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSSet* myVotes;
@property (nonatomic, retain) Election * forElection;
@property (nonatomic, retain) NSSet* friendVotes;

@end


@interface Measure (CoreDataGeneratedAccessors)
- (void)addMyVotesObject:(MeasureVote *)value;
- (void)removeMyVotesObject:(MeasureVote *)value;
- (void)addMyVotes:(NSSet *)value;
- (void)removeMyVotes:(NSSet *)value;

- (void)addFriendVotesObject:(FriendMeasureVote *)value;
- (void)removeFriendVotesObject:(FriendMeasureVote *)value;
- (void)addFriendVotes:(NSSet *)value;
- (void)removeFriendVotes:(NSSet *)value;

@end

