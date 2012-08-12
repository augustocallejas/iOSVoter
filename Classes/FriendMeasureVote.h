//
//  FriendMeasureVote.h
//  Supervote
//
//  Created by augusto callejas on 8/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Friend;
@class Measure;

@interface FriendMeasureVote :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * vote;
@property (nonatomic, retain) NSString * statement;
@property (nonatomic, retain) Friend * author;
@property (nonatomic, retain) Measure * forMeasure;

@end



