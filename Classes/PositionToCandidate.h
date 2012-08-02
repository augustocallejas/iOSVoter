//
//  PositionToCandidate.h
//  Supervote
//
//  Created by augusto callejas on 7/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Candidate;
@class Position;

@interface PositionToCandidate :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) Candidate * candidate;
@property (nonatomic, retain) Position * position;

@end



