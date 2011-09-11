//
//  Friend.h
//  Supervote
//
//  Created by augusto callejas on 9/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class FriendBallotVote;
@class FriendMeasureVote;

@interface Friend :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* votes;
@property (nonatomic, retain) NSSet* measures;

@end


@interface Friend (CoreDataGeneratedAccessors)
- (void)addVotesObject:(FriendBallotVote *)value;
- (void)removeVotesObject:(FriendBallotVote *)value;
- (void)addVotes:(NSSet *)value;
- (void)removeVotes:(NSSet *)value;

- (void)addMeasuresObject:(FriendMeasureVote *)value;
- (void)removeMeasuresObject:(FriendMeasureVote *)value;
- (void)addMeasures:(NSSet *)value;
- (void)removeMeasures:(NSSet *)value;

@end

