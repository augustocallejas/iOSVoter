//
//  FriendMeasureVote.h
//  Supervote
//
//  Created by augusto callejas on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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



