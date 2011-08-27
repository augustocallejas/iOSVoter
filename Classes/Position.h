//
//  Position.h
//  Supervote
//
//  Created by augusto callejas on 8/26/11.
//  Copyright 2011 Canary Falls Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Candidate;
@class Election;

@interface Position :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * level;
@property (nonatomic, retain) NSSet* candidates;
@property (nonatomic, retain) Election * election;

@end


@interface Position (CoreDataGeneratedAccessors)
- (void)addCandidatesObject:(Candidate *)value;
- (void)removeCandidatesObject:(Candidate *)value;
- (void)addCandidates:(NSSet *)value;
- (void)removeCandidates:(NSSet *)value;

@end

