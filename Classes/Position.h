//
//  Position.h
//  Supervote
//
//  Created by augusto callejas on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Candidate;
@class Election;

@interface Position :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * levelOrder;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * level;
@property (nonatomic, retain) NSNumber * titleOrder;
@property (nonatomic, retain) NSSet* candidates;
@property (nonatomic, retain) Election * election;

@end


@interface Position (CoreDataGeneratedAccessors)
- (void)addCandidatesObject:(Candidate *)value;
- (void)removeCandidatesObject:(Candidate *)value;
- (void)addCandidates:(NSSet *)value;
- (void)removeCandidates:(NSSet *)value;

@end

