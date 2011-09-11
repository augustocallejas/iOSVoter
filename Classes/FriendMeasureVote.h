//
//  FriendMeasureVote.h
//  Supervote
//
//  Created by augusto callejas on 9/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Friend;
@class Measure;

@interface FriendMeasureVote :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * vote;
@property (nonatomic, retain) NSString * statement;
@property (nonatomic, retain) Friend * author;
@property (nonatomic, retain) Measure * forMeasure;

@end



