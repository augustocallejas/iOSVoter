//
//  PoliticalParty.h
//  Supervote
//
//  Created by augusto callejas on 8/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Candidate;

@interface PoliticalParty :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* candidates;

@end


@interface PoliticalParty (CoreDataGeneratedAccessors)
- (void)addCandidatesObject:(Candidate *)value;
- (void)removeCandidatesObject:(Candidate *)value;
- (void)addCandidates:(NSSet *)value;
- (void)removeCandidates:(NSSet *)value;

@end

