//
//  Friend.h
//  Supervote
//
//  Created by augusto callejas on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class FacebookFriend;
@class FriendBallotVote;
@class FriendMeasureVote;

@interface Friend :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) FacebookFriend * facebook;
@property (nonatomic, retain) NSSet* measures;
@property (nonatomic, retain) NSSet* votes;

@end


@interface Friend (CoreDataGeneratedAccessors)
- (void)addMeasuresObject:(FriendMeasureVote *)value;
- (void)removeMeasuresObject:(FriendMeasureVote *)value;
- (void)addMeasures:(NSSet *)value;
- (void)removeMeasures:(NSSet *)value;

- (void)addVotesObject:(FriendBallotVote *)value;
- (void)removeVotesObject:(FriendBallotVote *)value;
- (void)addVotes:(NSSet *)value;
- (void)removeVotes:(NSSet *)value;

@end

