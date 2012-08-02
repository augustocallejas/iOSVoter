//
//  Position.h
//  Supervote
//
//  Created by augusto callejas on 7/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Election;
@class PositionToCandidate;

@interface Position :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * levelOrder;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * level;
@property (nonatomic, retain) NSNumber * titleOrder;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSSet* candidates;
@property (nonatomic, retain) Election * forElection;

@end


@interface Position (CoreDataGeneratedAccessors)
- (void)addCandidatesObject:(PositionToCandidate *)value;
- (void)removeCandidatesObject:(PositionToCandidate *)value;
- (void)addCandidates:(NSSet *)value;
- (void)removeCandidates:(NSSet *)value;

@end

