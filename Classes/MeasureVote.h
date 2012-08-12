//
//  MeasureVote.h
//  Supervote
//
//  Created by augusto callejas on 8/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Ballot;
@class Measure;

@interface MeasureVote :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * statement;
@property (nonatomic, retain) NSNumber * vote;
@property (nonatomic, retain) NSNumber * viewableByFriends;
@property (nonatomic, retain) Ballot * forBallot;
@property (nonatomic, retain) Measure * forMeasure;

@end



