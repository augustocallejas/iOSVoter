//
//  MeasureVote.h
//  Supervote
//
//  Created by augusto callejas on 8/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Ballot;

@interface MeasureVote :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * vote;
@property (nonatomic, retain) Ballot * forBallot;
@property (nonatomic, retain) NSManagedObject * forMeasure;

@end



